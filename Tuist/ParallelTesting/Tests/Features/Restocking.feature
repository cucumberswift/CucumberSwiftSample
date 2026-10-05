Feature: Restocking
  Each example of a Scenario Outline is a scenario of its own, so Xcode can hand each one
  to a different worker.

  Scenario Outline: A delivery adds to the stock
    Given the warehouse has <stock> "<product>"
    When a delivery of <delivered> "<product>" arrives
    Then the warehouse has <total> "<product>" in stock

    Examples:
      | product | stock | delivered | total |
      | mug     | 0     | 12        | 12    |
      | teapot  | 2     | 4         | 6     |
      | saucer  | 5     | 0         | 5     |
      | spoon   | 1     | 99        | 100   |
