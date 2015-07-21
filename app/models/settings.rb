class Settings < RailsSettings::CachedSettings
	def self.metrika_cart_goal_full
		"yaCounter#{Settings.metrika_id}.reachGoal('#{Settings.metrika_cart_goal}')" if Settings.metrika_id && Settings.metrika_cart_goal
	end
	def self.metrika_order_goal_full
		"yaCounter#{Settings.metrika_id}.reachGoal('#{Settings.metrika_order_goal}')" if Settings.metrika_id && Settings.metrika_order_goal
	end
end
