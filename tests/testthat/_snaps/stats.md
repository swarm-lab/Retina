# quantile() throws for probs > 1

    Code
      img$quantile(1.1)
    Condition
      Error:
      ! probs must be between 0 and 1

# quantile() throws for probs < 0

    Code
      img$quantile(-0.1)
    Condition
      Error:
      ! probs must be between 0 and 1

