require "test_helper"

class FraudEvaluationTest < ActiveSupport::TestCase
  setup do
    @transaction = transactions(:one)
  end

  test "should create fraud evaluation" do
    assert_difference("FraudEvaluation.count") do
      FraudEvaluation.create!(
        financial_transaction: @transaction,
        risk_score: 50,
        rules_triggered: "TEST_RULE"
      )
    end
  end
end
