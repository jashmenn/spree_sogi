module Sogi
  # fake class to avoid dealing with shipping amounts for now
  class NullShipping
    def calculate_shipping(order)
      nil
    end
  end
end
