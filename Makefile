# -*- mode: make; tab-width: 4; indent-tabs-mode: t -*-
# vim: ft=make noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

.PHONY: experiment

ifndef lock
    $(eval lock := true)
endif

_remove_state:
#	@rm -rf src/.terraform
	@rm -rf src/terraform.tfstate*.backup

########################################################################
# Single component approach
########################################################################

__setup:
ifndef env
	$(error Missing env)
endif

ifndef component
	$(error Missing component)
endif

ifndef aws_account
	$(eval aws_account := "neosperience-test-${env}")
endif

	# summary
	@echo "ENV:       ${aws_account}"
	@echo "COMPONENT: ${component}"
	terraform -version

_setup: __setup
	# init without downloading anything
	@rm -rf src/components/${component}/.terraform/*.tfstate
	cd src/components/$(component); AWS_PROFILE=${aws_account} terraform init \
		-backend=true \
		-backend-config="bucket=neosperience-test-terraform-${env}" \
		-backend-config="key=infra-${env}/$(component)/terraform.tfstate" \
		-get=false \
		-lockfile=${lock}


##
# init inits a component
#
# Usage:
# $ make init component=onelogin env=dev
##
init: __setup
	# remove state
	@rm -rf src/components/${component}/.terraform
	@rm -rf src/components/${component}/terraform.tfstate*.backup
	# setup backend
	cd src/components/$(component); AWS_PROFILE=${aws_account} terraform init \
		-backend=true \
		-backend-config="bucket=neosperience-test-terraform-${env}" \
		-backend-config="key=infra-${env}/$(component)/terraform.tfstate"


##
# init-upgrade inits a component
#
# Usage:
# $ make init-upgrade component=onelogin env=dev
##
init-upgrade: __setup
	# remove state
	@rm -rf src/components/${component}/.terraform
	@rm -rf src/components/${component}/terraform.tfstate*.backup
	# setup backend
	cd src/components/$(component); AWS_PROFILE=${aws_account} terraform init -upgrade \
		-backend=true \
		-backend-config="bucket=neosperience-test-terraform-${env}" \
		-backend-config="key=infra-${env}/$(component)/terraform.tfstate"

##
# Plan shows the execution plan.
#
# Usage:
# $ make plan component=onelogin env=dev
##
plan: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform plan \
		-var-file=../../../config/${env}/terraform.tfvars \
		-out=../../../${env}-${component}.tfplan \
		-lock=${lock}

##
# Plan shows the execution plan
#
# Usage:
# make planTarget component=onelogin env=dev
##
planTarget: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform plan \
		-var-file=../../../config/${env}/terraform.tfvars \
		-lock=${lock} \
		-target=${target}

##
# Apply the desired changes.
#
# Usage:
# make apply component=onelogin env=dev
##
apply: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform apply \
		-var-file=../../../config/${env}/terraform.tfvars \
		-lock=${lock}

##
# Apply the desired changes.
#
# Usage:
# make applyPlanFile component=onelogin env=dev
##
applyPlanFile: _setup
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform apply \
		-auto-approve \
		-lock=${lock} \
		../../../${env}-${component}.tfplan

##
# Apply the desired changes.
#
# Usage:
# make applyTarget component=onelogin env=dev
##
applyTarget: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform apply \
		-var-file=../../../config/${env}/terraform.tfvars \
		-lock=${lock} \
		-target=${target}

##
# Import
#
# Usage:
# make import component=onelogin env=dev resource=resource id=id
##
import: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform import \
		-var-file=../../../config/${env}/terraform.tfvars \
		-lock=${lock} \
		${resource} ${id}

##
# Manipulate state
#
# Usage:
# make state component=onelogin env=dev resource=resource action=action
##
state: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform state ${action} '${resource}'

##
# Manipulate state (mv)
#
# Usage:
# make state-mv component=onelogin env=dev resource=resource from=item to=item
##
state-mv: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform state mv ${from} ${to}

##
# Force unlock
#
# Usage:
# make force-unlock component=onelogin env=dev lockid=lockid
##
force-unlock: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform force-unlock ${action} \
		${lockid}

##
# Destroy component.
#
# Usage:
# make destroy component=onelogin env=dev
##
destroy: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform destroy \
		-var-file=../../../config/${env}/terraform.tfvars \
		-lock=${lock}

##
# terraform show.
#
# Usage:
# make show component=onelogin env=dev
##
show: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform show

##
# terraform refresh.
#
# Usage:
# make refresh component=onelogin env=dev
##
refresh: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform refresh \
		-var-file=../../../config/${env}/terraform.tfvars \
		-lock=${lock}

##
# Destroy component.
#
# Usage:
# make destroyTarget component=onelogin env=dev
##
destroyTarget: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform destroy \
		-var-file=../../../config/${env}/terraform.tfvars \
		-lock=${lock} \
		-target=${target}

##
# Taint a component. This does not change the resource, but marks it to be recreated on the next apply run.
#
# Usage:
# $ make taint component=onelogin env=dev
#        module=internal-api-web name=aws_elb.web-elb
##
taint: _setup
ifndef name
	$(error Missing name)
endif
ifdef module
	${eval module_args := -module ${module}}
endif
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform taint \
		-lock=${lock} \
		${module_args} \
		${name}

##
# Output prints the output values from the statefile
#
# Usage:
# $ make output component=onelogin env=dev
##
output: _setup
	@cd src/components/${component}; AWS_PROFILE=${aws_account} terraform output

########################################################################
# Other

console: _setup
	@rm -f ${env}-${component}.tfplan
	cd src/components/${component}; AWS_PROFILE=${aws_account} terraform console \
		-var-file=../../../config/${env}/terraform.tfvars


format:
	terraform fmt src
	terraform fmt config