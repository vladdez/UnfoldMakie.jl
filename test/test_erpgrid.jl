data, pos = TopoPlots.example_data()
data = data[:, :, 1]

#times = -0.099609375:0.001953125:1.0

@testset "basic erpgrid: one plot is out of the border" begin
    plot_erpgrid(data[1:3, 1:20], pos)
end

@testset "basic erpgrid" begin
    plot_erpgrid(data[1:6, 1:20], pos)
end

@testset "erpgrid with GridPosition" begin
    f = Figure()
    plot_erpgrid!(f[1, 1], data, pos)
end

@testset "erpgrid plot in GridLayout" begin
    f = Figure(resolution=(1200, 1400))
    ga = f[1, 1] = GridLayout()
    plot_erpgrid!(ga, data, pos)
    f
end
