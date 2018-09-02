#conversion tests
@testset "testing conversion of exceptional values" begin
  @test convert(Posit8, NaN) == MLPosit.nan(Posit8)
  @test convert(Posit8, 0.0) == MLPosit.zero(Posit8)
  @test convert(Posit8, -0.0) == MLPosit.zero(Posit8)
end

@testset "comprehensive conversion back and forth from Float64" begin
  for idx = 0x00:0xFF
      a = reinterpret(Posit8, idx)
      fa = convert(Float64, a)
      b = convert(Posit8, fa)
      @test a == b
      if !(isnan(a))
          @test fa == convert(Float64, b)
      end
  end
end
