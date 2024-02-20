class PasswordLock
  def initialize(@password : Int32 | String | Float64)
  end

  def encrypt
    if @password.is_a?(Int32)
      @password = (@password.as(Int32) / 2).round
    elsif @password.is_a?(Float64)
      @password *= 4
    else
      @password = @password.as(String).reverse
    end
  end

  def unlock?(pass : Int32 | String | Float64)
    if pass.is_a?(Int32)
      (pass.as(Int32) / 2).round == @password ? "Unlocked" : nil
    elsif pass.is_a?(Float64)
      pass.as(Float64) * 4 == @password ? "Unlocked" : nil
    else
      pass.as(String).reverse == @password ? "Unlocked" : nil
    end
  end
end
