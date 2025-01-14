# ![UnfoldMakie - Advanced EEG and ERP Plotting](https://github.com/unfoldtoolbox/UnfoldMakie.jl/assets/57703446/26b770b3-afa0-4652-b654-82d2f737f42f)


[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://unfoldtoolbox.github.io/UnfoldMakie.jl/dev)
[![Build Status](https://github.com/unfoldtoolbox/UnfoldMakie.jl/workflows/CI/badge.svg)](https://github.com/unfoldtoolbox/UnfoldMakie.jl/actions)
[![Coverage](https://codecov.io/gh/behinger/UnfoldMakie.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/behinger/UnfoldMakie.jl)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6531996.svg)](https://doi.org/10.5281/zenodo.6531996)

|rERP|EEG visualisation|EEG Simulations|BIDS pipeline|Decode EEG data|Statistical testing|
|---|---|---|---|---|---|
| <a href="https://github.com/unfoldtoolbox/Unfold.jl/tree/main"><img src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277623787-757575d0-aeb9-4d94-a5f8-832f13dcd2dd.png"></a> | <a href="https://github.com/unfoldtoolbox/UnfoldMakie.jl"><img  src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277623793-37af35a0-c99c-4374-827b-40fc37de7c2b.png"></a>|<a href="https://github.com/unfoldtoolbox/UnfoldSim.jl"><img src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277623795-328a4ccd-8860-4b13-9fb6-64d3df9e2091.png"></a>|<a href="https://github.com/unfoldtoolbox/UnfoldBIDS.jl"><img src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277622460-2956ca20-9c48-4066-9e50-c5d25c50f0d1.png"></a>|<a href="https://github.com/unfoldtoolbox/UnfoldDecode.jl"><img src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277622487-802002c0-a1f2-4236-9123-562684d39dcf.png"></a>|<a href="https://github.com/unfoldtoolbox/UnfoldStats.jl"><img  src="https://github-production-user-asset-6210df.s3.amazonaws.com/10183650/277623799-4c8f2b5a-ea84-4ee3-82f9-01ef05b4f4c6.png"></a>|

A toolbox for  visualizations of EEG/ERP data and Unfold.jl models.
Building on the [Unfold](https://github.com/unfoldtoolbox/unfold.jl/) and [Makie](https://makie.juliaplots.org/stable/), it grants users high performance, and highly customizable plots.

We currently support: 
<img  src="https://github.com/unfoldtoolbox/UnfoldMakie.jl/assets/10183650/af2801e5-cd64-4932-b84d-9abc1d8470ee" width="300" align="right">
- ![icon_erpplot_20px](https://github.com/unfoldtoolbox/UnfoldMakie.jl/assets/10183650/22c8472d-df78-46d7-afe8-e1e4e7b04313)
ERP plots
- ![icon_butterfly_20px](https://github.com/unfoldtoolbox/UnfoldMakie.jl/assets/10183650/30b86665-3705-4258-bffa-97abcd308235)
Butterfly plots
- ![icon_topoplot_20px](https://github.com/unfoldtoolbox/UnfoldMakie.jl/assets/10183650/ea91f14f-30df-4316-997b-56bc411c9276)
Topography plots
- ![icon_toposeries_20px](https://github.com/unfoldtoolbox/UnfoldMakie.jl/assets/10183650/eceab5d6-88c7-41ae-b0d8-5ca652e83b40)
Topography time series
- ![icon_erpgrid_20px](https://github.com/unfoldtoolbox/UnfoldMakie.jl/assets/10183650/83b42a21-439a-49fd-80bc-cd82872695e9)
ERP grid
- ![icon_erpimage_20px](https://github.com/unfoldtoolbox/UnfoldMakie.jl/assets/10183650/b45b0547-7333-4d28-9ac8-33a989b7c132)
ERP images
- ![icon_channelimage_20px](https://github.com/unfoldtoolbox/UnfoldMakie.jl/assets/10183650/7ea16a7a-879a-4dcc-aaab-bc97211910ba)
Channel images
- ![icon_parallel_20px](https://github.com/unfoldtoolbox/UnfoldMakie.jl/assets/10183650/dab097c3-bcd6-4405-a44b-71cbe3e5fac9)
Parallel coordinates
- Designmatrices
- Circular topoplots


## Install

### Installing Julia

<details>
<summary>Click to expand</summary>

The recommended way to install julia is [juliaup](https://github.com/JuliaLang/juliaup).
It allows you to, e.g., easily update Julia at a later point, but also test out alpha/beta versions etc.

TL:DR; If you dont want to read the explicit instructions, just copy the following command

#### Windows

AppStore -> JuliaUp,  or `winget install julia -s msstore` in CMD

#### Mac & Linux

`curl -fsSL https://install.julialang.org | sh` in any shell
</details>

### Installing Unfold

```julia
using Pkg
Pkg.add("UnfoldMakie")
```

## Quickstart

```julia
using UnfoldMakie
using CairoMakie # backend
using Unfold,UnfoldSim # Fit / Simulation

data, evts = UnfoldSim.predef_eeg(; noiselevel = 12, return_epoched = true)
data = reshape(data,1,size(data)...) # fake a single channel
	
times = range(0, step = 1 / 100, length = size(data, 2))
m = fit(UnfoldModel,@formula(0~1+condition),evts,data,times)

plot_erp(coeftable(m))
```

## Contributions

Contributions are very welcome. These could be typos, bugreports, feature-requests, speed-optimization, new solvers, better code, better documentation.

### How-to Contribute

You are very welcome to raise issues and start pull requests!

### Adding Documentation

1. We recommend to write a Literate.jl document and place it in `docs/literate/FOLDER/FILENAME.jl` with `FOLDER` being `HowTo`, `Explanation`, `Tutorial` or `Reference` ([recommended reading on the 4 categories](https://documentation.divio.com/)).
2. Literate.jl converts the `.jl` file to a `.md` automatically and places it in `docs/src/generated/FOLDER/FILENAME.md`.
3. Edit [make.jl](https://github.com/unfoldtoolbox/Unfold.jl/blob/main/docs/make.jl) with a reference to `docs/src/generated/FOLDER/FILENAME.md`.

## Citation

If you make use of theses visualizations, please cite:

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6531996.svg)](https://doi.org/10.5281/zenodo.6531996)

## Contributors (alphabetically)

- **Daniel Baumgartner**
- **Benedikt Ehinger**
- **Sören Döring**
- **Niklas Gärtner**
- **Furkan Lokman**
- **Vladimir Mikheev**

## Acknowledgements

Funded by the Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) – project ID 251654672 – TRR 161 (project D05)

Funded by Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) under Germany´s Excellence Strategy – EXC 2075 – 390740016
