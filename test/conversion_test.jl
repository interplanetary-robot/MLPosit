@testset "testing the breakdown function for 64-bit floats" begin
   #test signs
   @test MLPosit.breakdown(1.0) == (false, 0, 0x0000)
   @test MLPosit.breakdown(-1.0) == (true, 0, 0x0000)

   #test exponents of two.
   @test MLPosit.breakdown(2.0) == (false, 1, 0x0000)
   @test MLPosit.breakdown(4.0) == (false, 2, 0x0000)
   @test MLPosit.breakdown(0.5) == (false, -1, 0x0000)
   @test MLPosit.breakdown(0.25) == (false, -2, 0x0000)

   #test fraction values.  These are shifted by three to allow prefix prepending.
   @test MLPosit.breakdown(1.5) == (false, 0, 0x1000)
   @test MLPosit.breakdown(-1.5) == (true, 0, 0x1000)
   @test MLPosit.breakdown(1.25) == (false, 0, 0x0800)
end

@testset "testing the breakdown fuction for 32-bit floats" begin
end

@testset "testing the assemble fuction" begin
  #test basic numbers that are just powers of two: positive
  @test MLPosit.assemble(Int16(0), 0x0000) == 0b0100_0000_0000_0000
  @test MLPosit.assemble(Int16(1), 0x0000) == 0b0110_0000_0000_0000
  @test MLPosit.assemble(Int16(2), 0x0000) == 0b0111_0000_0000_0000
  #test basic numbers that are just powers of two: negative
  @test MLPosit.assemble(Int16(-1), 0x0000) == 0b0010_0000_0000_0000
  @test MLPosit.assemble(Int16(-2), 0x0000) == 0b0001_0000_0000_0000

  #test that fractions work
  @test MLPosit.assemble(Int16(0), 0x1000) == 0b0101_0000_0000_0000
  @test MLPosit.assemble(Int16(0), 0x0800) == 0b0100_1000_0000_0000
  @test MLPosit.assemble(Int16(2), 0x1000) == 0b0111_0100_0000_0000
  @test MLPosit.assemble(Int16(-1), 0x1000) == 0b0011_0000_0000_0000
  @test MLPosit.assemble(Int16(-1), 0x0800) == 0b0010_1000_0000_0000
  @test MLPosit.assemble(Int16(-3), 0x1000) == 0b0000_1100_0000_0000
end

@testset "testing analysis via the finishing fuction" begin
  #test basic numbers that are just powers of two: positive
  @test MLPosit.finishing(0x0010) == (0x00, false, false, true)
  @test MLPosit.finishing(0x0080) == (0x00, false, true, false)
  @test MLPosit.finishing(0x0090) == (0x00, false, true, true)
  @test MLPosit.finishing(0x0100) == (0x01, true, false, false)
  @test MLPosit.finishing(0x0110) == (0x01, true, false, true)
  @test MLPosit.finishing(0x0180) == (0x01, true, true, false)
  @test MLPosit.finishing(0x0190) == (0x01, true, true, true)
end
