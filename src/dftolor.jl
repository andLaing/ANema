using DataFrames
using HDF5
using PhysicalConstants
using PhysicalConstants.CODATA2018
using Unitful

import Unitful:
    nm, μm, mm, cm, ns, μs, ms, ps, s

@enum Dtsel dtfirst dtminimum dtaverage
@enum Possel postrue posreco posrecall

"""
	MlemLor

Struct representing a LOR
"""
struct MlemLor
    dx::Float32
    x1::Float32
    y1::Float32
    z1::Float32
    x2::Float32
    y2::Float32
    z2::Float32
end

"""
	write_lors_hdf5(filename, mlor)
	Write lors in a hdf5 format required by petalorust (mlem algo)
"""
function write_lors_hdf5(filename, mlor)

    function set_datatype(::Type{MlemLor})
        dtype = HDF5.h5t_create(HDF5.H5T_COMPOUND, sizeof(MlemLor))
        HDF5.h5t_insert(dtype, "dx", fieldoffset(MlemLor, 1),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "x1", fieldoffset(MlemLor, 2),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "y1", fieldoffset(MlemLor, 3),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "z1", fieldoffset(MlemLor, 4),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "x2", fieldoffset(MlemLor, 5),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "y2", fieldoffset(MlemLor, 6),
                        datatype(Float32))
        HDF5.h5t_insert(dtype, "z2", fieldoffset(MlemLor, 7),
                        datatype(Float32))

        HDF5.Datatype(dtype)
    end

    h5f = h5open(filename, "w")

    dtype = set_datatype(MlemLor)
    dspace = dataspace(mlor)
    grp = create_group(h5f, "true_info")
    dset = create_dataset(grp, "lors", dtype, dspace)
    write_dataset(dset, dtype, mlor)


    close(h5f)
end

"""
	radial_correction(xb::Vector{T}, yb::Vector{T},zb::Vector{T},
	                            r::Vector{T}) where T
Computes the radial correction from barycenter
"""
function radial_correction(xb::Vector{T}, yb::Vector{T},zb::Vector{T},
                            r::Vector{T}) where T
    ϕ = atan.(yb,xb)
    x = r .* cos.(ϕ)
    y = r .* sin.(ϕ)
    return x,y,zb
end


"""
    deltatime(df::DataFrame, t::Dtsel=dtfirst)
    @enum Dtsel dtfirst dtminimum dtaverage

Return t2 - t1 where t1 and t2 are:
dtfirst for nominal (true) time
dtminimum for minimum time stamp of all SiPMs
dtaverage for average time stamp of 5 minimum SiPMs
"""
function deltatime(df::DataFrame, t::Dtsel=dtfirst)
    if t     == dtminimum
        return  uconvert.(ps, df.tr2 - df.tr1)
    elseif t == dtaverage
        return uconvert.(ps,df.ta2 - df.ta1)
    else
        return uconvert.(ps, df.t2 - df.t1)

    end
end

"""
    cdoi(df::DataFrame, position::Possel=postrue, nlxe::Number=1.6)
    @enum Possel postrue posreco

Return the time correction associated to DOI (depth of interaction)
position:
  posreco: if using reconstructed values
  postrue: if using true values

"""
function cdoi(df::DataFrame, r1::Vector{Float64}, r2::Vector{Float64},
              position::Possel=postrue, nlxe::Number=1.6)
    clxe = SpeedOfLightInVacuum/nlxe

    if position == posreco
        dxrb1 = [dxyz([df.x1[i], df.y1[i], df.z1[i]],
                              [df.xb1[i], df.yb1[i], df.zb1[i]]) for i in 1:nrow(df)]

        dxrb2 = [dxyz([df.x2[i], df.y2[i], df.z2[i]],
                              [df.xb2[i], df.yb2[i], df.zb2[i]]) for i in 1:nrow(df)]

    elseif position == posrecall

        xq1,yq1,zq1 =  radial_correction(df.xr1./mm, df.yr1./mm, df.zr1./mm, r1)
        xq2,yq2,zq2 =  radial_correction(df.xr2./mm, df.yr2./mm, df.zr2./mm, r2)

        dxrb1 = [dxyz([xq1[i]*mm, yq1[i]*mm, zq1[i]*mm],
                              [df.xb1[i], df.yb1[i], df.zb1[i]]) for i in 1:nrow(df)]

        dxrb2 = [dxyz([xq2[i]*mm, yq2[i]*mm, zq2[i]*mm],
                              [df.xb2[i], df.yb2[i], df.zb2[i]]) for i in 1:nrow(df)]

    else
        dxrb1 = [dxyz([df.xt1[i], df.yt1[i], df.zt1[i]],
                              [df.xb1[i], df.yb1[i], df.zb1[i]]) for i in 1:nrow(df)]

        dxrb2 = [dxyz([df.xt2[i], df.yt2[i], df.zt2[i]],
                              [df.xb2[i], df.yb2[i], df.zb2[i]]) for i in 1:nrow(df)]

    end
    return uconvert.(ps, (dxrb2 - dxrb1)/clxe)
end


function cdoi(df::DataFrame, position::Possel=postrue, reco="phistd", nlxe::Number=1.6)
    if reco == "phistd"
        return cdoi(df, df.r1p./mm , df.r2p./mm, position, nlxe)
    elseif reco == "zstd"
        return cdoi(df, df.r1z./mm , df.r2z./mm, position, nlxe)
    else
        return cdoi(df, df.r1./mm , df.r2./mm, position, nlxe)
    end
end


function ctsr(df::DataFrame, position::Possel=postrue)
    cc = float(SpeedOfLightInVacuum)
    if position == postrue
        tsr1 = [dxyz([df.xt1[i], df.yt1[i], df.zt1[i]],
                             [df.xs[i], df.ys[i], df.zs[i]]) for i in 1:nrow(df)]/cc
        tsr2 = [dxyz([df.xt2[i], df.yt2[i], df.zt2[i]],
                             [df.xs[i], df.ys[i], df.zs[i]]) for i in 1:nrow(df)]/cc

    else
        tsr1 = [dxyz([df.x1[i], df.y1[i], df.z1[i]],
                             [df.xs[i], df.ys[i], df.zs[i]]) for i in 1:nrow(df)]/cc
        tsr2 = [dxyz([df.x2[i], df.y2[i], df.z2[i]],
                             [df.xs[i], df.ys[i], df.zs[i]]) for i in 1:nrow(df)]/cc
    end
    return uconvert.(ps, tsr2 - tsr1)
end

"""
    crt(dfu, dtsel=dtfirst, posel=postrue)

Return the CRT of the system
"""
function crt(dfu, r1::Vector{Float64}, r2::Vector{Float64}, dtsel=dtfirst, posel=postrue)

    dt12 = deltatime(dfu, dtsel)
    t12 = dt12./ps

    dtsr12 = ctsr(dfu, postrue)   # this is a nominal position for CRT
    tsr12 = dtsr12./ps

    dtrb12 = cdoi(dfu, r1, r2, posel)
    trb12 = dtrb12 ./ps

    dt = t12 - tsr12 - trb12

end

"""
    dftolor(df::DataFrame, t::Dtsel=dtfirst, position::Possel=postrue, nlxe::Number=1.6)

Take dataframe df and return a vector of MlemLor.
Since MlemLor will be written to file, remove units (e.g, use implicit units, in this
case mm) and transform to Float32
"""
function dftolor(df::DataFrame, t::Dtsel=dtfirst, position::Possel=postrue, nlxe::Number=1.6)

    function tof32(l)
        Float32.(l/mm)
    end

    dt12  = deltatime(df,t)
    dtdoi = cdoi(df,position)
    # compute dx from time and speed of light, ensure that the result is in mm
    dx    = uconvert.(mm, (dt12 - dtdoi) * SpeedOfLightInVacuum)

    if position == postrue
        x1, x2, y1, y2, z1, z2 = df.xt1, df.xt2, df.yt1, df.yt2, df.zt1, df.zt2
    else
        x1, x2, y1, y2, z1, z2 = df.x1,  df.x2,  df.y1,  df.y2,  df.z1,  df.z2
    end

    MlemLor.(tof32(dx),tof32(x1),tof32(y1),tof32(z1), tof32(x2), tof32(y2), tof32(z2))
end
