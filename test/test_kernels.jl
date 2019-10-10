using Test
using LinearAlgebra
using KernelFunctions
using SpecialFunctions

x = rand()*2; v1 = rand(3); v2 = rand(3)
@testset "Kappa functions of kernels" begin
    @testset "Constant" begin
        @testset "ZeroKernel" begin
            k = ZeroKernel()
            @test eltype(k) == Any
            @test kappa(k,2.0) == 0.0
        end
        @testset "WhiteKernel" begin
            k = WhiteKernel()
            @test eltype(k) == Any
            @test kappa(k,1.0) == 1.0
            @test kappa(k,0.0) == 0.0
        end
        @testset "ConstantKernel" begin
            c = 2.0
            k = ConstantKernel(c)
            k₂ = ConstantKernel(IdentityTransform(),c)
            @test eltype(k) == Any
            @test kappa(k,1.5)== kappa(k₂,1.5)
            @test kappa(k,1.0) == c
            @test kappa(k,0.5) == c
        end
    end
    @testset "Exponential" begin
        @testset "SqExponentialKernel" begin
            k = SqExponentialKernel()
            @test kappa(k,x) ≈ exp(-x)
            @test k(v1,v2) ≈ exp(-norm(v1-v2)^2)
            l = 0.5
            k = SqExponentialKernel(l)
            @test k(v1,v2) ≈ exp(-l^2*norm(v1-v2)^2)
            v = rand(3)
            k = SqExponentialKernel(v)
            @test k(v1,v2) ≈ exp(-norm(v.*(v1-v2))^2)
        end
        @testset "ExponentialKernel" begin
            k = ExponentialKernel()
            @test kappa(k,x) ≈ exp(-x)
            @test k(v1,v2) ≈ exp(-norm(v1-v2))
            l = 0.5
            k = ExponentialKernel(l)
            @test k(v1,v2) ≈ exp(-l*norm(v1-v2))
            v = rand(3)
            k = ExponentialKernel(v)
            @test k(v1,v2) ≈ exp(-norm(v.*(v1-v2)))
        end
        @testset "GammaExponentialKernel" begin
            k = GammaExponentialKernel(1.0,2.0)
            @test kappa(k,x) ≈ exp(-(x)^(k.γ))
            @test k(v1,v2) ≈ exp(-norm(v1-v2)^(2k.γ))
            l = 0.5
            k = GammaExponentialKernel(l,1.5)
            @test k(v1,v2) ≈ exp(-l^(3.0)*norm(v1-v2)^(3.0))
            v = rand(3)
            k = GammaExponentialKernel(v,3.0)
            @test k(v1,v2) ≈ exp(-norm(v.*(v1-v2)).^6.0)
        end
    end
    @testset "Exponentiated" begin
        @testset "ExponentiatedKernel" begin
            k = ExponentiatedKernel()
            @test kappa(k,x) ≈ exp(x)
            @test kappa(k,-x) ≈ exp(-x)
            @test k(v1,v2) ≈ exp(dot(v1,v2))
            l = 0.5
            k = ExponentiatedKernel(l)
            @test k(v1,v2) ≈ exp(l^2*dot(v1,v2))
            v = rand(3)
            k = ExponentiatedKernel(v)
            @test k(v1,v2) ≈ exp(dot(v.*v1,v.*v2))
        end
    end
    @testset "Matern" begin
        @testset "MaternKernel" begin
            ν = 2.0
            k = MaternKernel(1.0,ν)
            matern(x,ν) = 2^(1-ν)/gamma(ν)*(sqrt(2ν)*x)^ν*besselk(ν,sqrt(2ν)*x)
            @test kappa(k,x) ≈ matern(x,ν)
            @test kappa(k,0.0) == 1.0
            l = 0.5; ν = 3.0
            k = MaternKernel(l,ν)
            @test k(v1,v2) ≈ matern(l*norm(v1-v2),ν)
            v = rand(3); ν = 2.1
            k = MaternKernel(v,ν)
            @test k(v1,v2) ≈ matern(norm(v.*(v1-v2)),ν)
        end
        @testset "Matern32Kernel" begin
            k = Matern32Kernel()
            @test kappa(k,x) ≈ (1+sqrt(3)*x)exp(-sqrt(3)*x)
            @test k(v1,v2) ≈ (1+sqrt(3)*norm(v1-v2))exp(-sqrt(3)*norm(v1-v2))
            l = 0.5
            k = Matern32Kernel(l)
            @test k(v1,v2) ≈ (1+l*sqrt(3)*norm(v1-v2))exp(-l*sqrt(3)*norm(v1-v2))
            v = rand(3)
            k = Matern32Kernel(v)
            @test k(v1,v2) ≈ (1+sqrt(3)*norm(v.*(v1-v2)))exp(-sqrt(3)*norm(v.*(v1-v2)))
        end
        @testset "Matern52Kernel" begin
            k = Matern52Kernel()
            @test kappa(k,x) ≈ (1+sqrt(5)*x+5/3*x^2)exp(-sqrt(5)*x)
            @test k(v1,v2) ≈ (1+sqrt(5)*norm(v1-v2)+5/3*norm(v1-v2)^2)exp(-sqrt(5)*norm(v1-v2))
            l = 0.5
            k = Matern52Kernel(l)
            @test k(v1,v2) ≈ (1+l*sqrt(5)*norm(v1-v2)+l^2*5/3*norm(v1-v2)^2)exp(-l*sqrt(5)*norm(v1-v2))
            v = rand(3)
            k = Matern52Kernel(v)
            @test k(v1,v2) ≈ (1+sqrt(5)*norm(v.*(v1-v2))+5/3*norm(v.*(v1-v2))^2)exp(-sqrt(5)*norm(v.*(v1-v2)))
        end
        @testset "Coherence Materns" begin
            x = 0.5
            @test kappa(MaternKernel(1.0,0.5),x) ≈ kappa(ExponentialKernel(),x)
            @test kappa(MaternKernel(1.0,1.5),x) ≈ kappa(Matern32Kernel(),x)
            @test kappa(MaternKernel(1.0,2.5),x) ≈ kappa(Matern52Kernel(),x)
        end
    end
    @testset "Polynomial" begin
        c = randn();

    end
    @testset "RationalQuadratic" begin
    end
end
