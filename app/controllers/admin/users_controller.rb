class Admin::UsersController < Admin::BaseController
	actions_except [:clone]
	index_attributes [:name, :card_number, :discount]
	private

	def permitted_params
		params.require(:user).permit(:name, :card_number, :discount, :email, :password)
	end
end
