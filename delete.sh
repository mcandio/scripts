export AWS_PROFILE=

function delete_policies() {
  policy_arn=$(aws iam list-policies --max-items 1000 --scope Local --no-paginate | jq -r '.Policies[] | select(.PolicyName|match("")) | .Arn')
  echo "${policy_arn}" | while read -r policy; do
    attached_role=$(aws iam list-entities-for-policy --policy-arn $policy | jq -r '.PolicyRoles[].RoleName')
    echo "detach role $attached_role from policy $policy"
    aws iam detach-role-policy --role-name $attached_role --policy-arn $policy
    echo "delete $policy"
    aws iam delete-policy --policy-arn $policy
  done
}

function delete_role() {
  role_name=$(aws iam list-roles --max-items 100 --profile agot-develop --no-paginate | jq -r '.Roles[] | select(.RoleName|match("")) | .RoleName'  | grep -vE 'assume')
  echo "${role_name}" | while read -r role; do
  echo "deleting role-policy from role $role"
  #aws iam detach-role-policy --role-name $role --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
  aws iam detach-role-policy --role-name $role --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
  echo ""
  echo "deleting role $role"
  aws iam delete-role --role-name $role
  done
}

function remove_role_from_instance_profile() {
  instance_profile=$(aws iam list-instance-profiles --max-items 1000 --no-paginate | jq -r '.InstanceProfiles[] | select(.InstanceProfileName|match("match")) | .InstanceProfileName  + " " +  .Roles[].RoleName' | grep -vE '')
  echo "${instance_profile}" | while read -r instance_profile; do
  nome=$(echo $instance_profile | awk '{print $1}')
  role=$(echo $instance_profile | awk '{print $2}')
  echo $nome
  echo $role
  echo "removing role $role from instance profile $nome"
  aws iam remove-role-from-instance-profile --instance-profile-name $nome --role-name $role
  echo "deleting role $role"
  aws iam detach-role-policy --role-name $role --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
  aws iam delete-role --role-name $role
  done
}

delete_role