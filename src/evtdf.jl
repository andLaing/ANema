using DataFrames
using Unitful

import Unitful:
    nm, μm, mm, cm, ns, μs, ms, ps, s

"""
    setunits(df::DataFrame)

Return a dataframe for lor computation where quantities are defined with their units
"""

function setunits(df::DataFrame, schema="v2")

    if schema == "v1"
        DataFrame(
            nsipm1 = df.nsipm1,     # number of sipms in cluster
            nsipm2 = df.nsipm2,

            q1 = df.q1,             # q in pes
            q2 = df.q2,

            r1  = df.r1  * mm,      # best radius
            r1q = df.r1q * mm,      # raw radius from q
            r2  = df.r2  * mm,
            r2q = df.r2q * mm,

            t1  = df.t1  * ns,      # time true
            t2  = df.t2  * ns,
            ta1 = df.ta1 * ns,      # average (over 5 mimimum in t)
            ta2 = df.ta2 * ns,
            tr1 = df.tr1 * ns,      # reco (smeared take minimum)
            tr2 = df.tr2 * ns,

            ux = df.ux,             # unit direction vector of gammas
            uy = df.uy,
            uz = df.uz,

            x1  = df.x1  * mm,      # best reco position
            x2  = df.x2  * mm,
            xb1 = df.xb1 * mm,      # position of sipm that gives time stamp
            xb2 = df.xb2 * mm,
            xr1 = df.xr1 * mm,      # reco position
            xr2 = df.xr2 * mm,
            xs  = df.xs  * mm,      # position of source
            xt1 = df.xt1 * mm,      # true position
            xt2 = df.xt2 * mm,

            y1  = df.y1  * mm,
            y2  = df.y2  * mm,
            yb1 = df.yb1 * mm,
            yb2 = df.yb2 * mm,
            yr1 = df.yr1 * mm,
            yr2 = df.yr2 * mm,
            ys  = df.ys  * mm,
            yt1 = df.yt1 * mm,
            yt2 = df.yt2 * mm,

            z1  = df.z1  * mm,
            z2  = df.z2  * mm,
            zb1 = df.zb1 * mm,
            zb2 = df.zb2 * mm,
            zr1 = df.zr1 * mm,
            zr2 = df.zr2 * mm,
            zs  = df.zs  * mm,
            zt1 = df.zt1 * mm,
            zt2 = df.zt2 * mm,

        )
    elseif schema == "v2"
        DataFrame(

            nsipm1 = df.nsipm1,     # number of sipms in cluster
            nsipm2 = df.nsipm2,

            q1 = df.q1,             # q in pes
            q2 = df.q2,

            r1  = df.r1  * mm,      # best radius
            r2  = df.r2  * mm,

            t1  = df.t1  * ns,      # time true
            t2  = df.t2  * ns,
            ta1 = df.ta1 * ns,      # average (over 5 mimimum in t)
            ta2 = df.ta2 * ns,
            tr1 = df.tr1 * ns,      # reco (smeared take minimum)
            tr2 = df.tr2 * ns,

            ux = df.ux,             # unit direction vector of gammas
            uy = df.uy,
            uz = df.uz,

            x1  = df.x1  * mm,      # best reco position
            x2  = df.x2  * mm,
            xb1 = df.xb1 * mm,      # position of sipm that gives time stamp
            xb2 = df.xb2 * mm,
            xr1 = df.xr1 * mm,      # reco position
            xr2 = df.xr2 * mm,
            xs  = df.xs  * mm,      # position of source
            xt1 = df.xt1 * mm,      # true position
            xt2 = df.xt2 * mm,

            y1  = df.y1  * mm,
            y2  = df.y2  * mm,
            yb1 = df.yb1 * mm,
            yb2 = df.yb2 * mm,
            yr1 = df.yr1 * mm,
            yr2 = df.yr2 * mm,
            ys  = df.ys  * mm,
            yt1 = df.yt1 * mm,
            yt2 = df.yt2 * mm,

            z1  = df.z1  * mm,
            z2  = df.z2  * mm,
            zb1 = df.zb1 * mm,
            zb2 = df.zb2 * mm,
            zr1 = df.zr1 * mm,
            zr2 = df.zr2 * mm,
            zs  = df.zs  * mm,
            zt1 = df.zt1 * mm,
            zt2 = df.zt2 * mm,
        )
elseif schema == "phistd"
    DataFrame(

        nsipm1 = df.nsipm1,     # number of sipms in cluster
        nsipm2 = df.nsipm2,

        q1 = df.q1,             # q in pes
        q2 = df.q2,

        r1  = df.r1  * mm,      # best radius
        r2  = df.r2  * mm,

        r1p  = df.r1p  * mm,      # best radius
        r2p  = df.r2p  * mm,

        t1  = df.t1  * ns,      # time true
        t2  = df.t2  * ns,
        ta1 = df.ta1 * ns,      # average (over 5 mimimum in t)
        ta2 = df.ta2 * ns,
        tr1 = df.tr1 * ns,      # reco (smeared take minimum)
        tr2 = df.tr2 * ns,

        ux = df.ux,             # unit direction vector of gammas
        uy = df.uy,
        uz = df.uz,

        x1  = df.x1  * mm,      # best reco position
        x2  = df.x2  * mm,
        xb1 = df.xb1 * mm,      # position of sipm that gives time stamp
        xb2 = df.xb2 * mm,
        xr1 = df.xr1 * mm,      # reco position
        xr2 = df.xr2 * mm,
        xs  = df.xs  * mm,      # position of source
        xt1 = df.xt1 * mm,      # true position
        xt2 = df.xt2 * mm,

        y1  = df.y1  * mm,
        y2  = df.y2  * mm,
        yb1 = df.yb1 * mm,
        yb2 = df.yb2 * mm,
        yr1 = df.yr1 * mm,
        yr2 = df.yr2 * mm,
        ys  = df.ys  * mm,
        yt1 = df.yt1 * mm,
        yt2 = df.yt2 * mm,

        z1  = df.z1  * mm,
        z2  = df.z2  * mm,
        zb1 = df.zb1 * mm,
        zb2 = df.zb2 * mm,
        zr1 = df.zr1 * mm,
        zr2 = df.zr2 * mm,
        zs  = df.zs  * mm,
        zt1 = df.zt1 * mm,
        zt2 = df.zt2 * mm,
    )
elseif schema == "zstd"
    DataFrame(

        nsipm1 = df.nsipm1,     # number of sipms in cluster
        nsipm2 = df.nsipm2,

        q1 = df.q1,             # q in pes
        q2 = df.q2,

        r1  = df.r1  * mm,      # best radius
        r2  = df.r2  * mm,

        r1z  = df.r1z  * mm,      # best radius
        r2z  = df.r2z  * mm,

        t1  = df.t1  * ns,      # time true
        t2  = df.t2  * ns,
        ta1 = df.ta1 * ns,      # average (over 5 mimimum in t)
        ta2 = df.ta2 * ns,
        tr1 = df.tr1 * ns,      # reco (smeared take minimum)
        tr2 = df.tr2 * ns,

        ux = df.ux,             # unit direction vector of gammas
        uy = df.uy,
        uz = df.uz,

        x1  = df.x1  * mm,      # best reco position
        x2  = df.x2  * mm,
        xb1 = df.xb1 * mm,      # position of sipm that gives time stamp
        xb2 = df.xb2 * mm,
        xr1 = df.xr1 * mm,      # reco position
        xr2 = df.xr2 * mm,
        xs  = df.xs  * mm,      # position of source
        xt1 = df.xt1 * mm,      # true position
        xt2 = df.xt2 * mm,

        y1  = df.y1  * mm,
        y2  = df.y2  * mm,
        yb1 = df.yb1 * mm,
        yb2 = df.yb2 * mm,
        yr1 = df.yr1 * mm,
        yr2 = df.yr2 * mm,
        ys  = df.ys  * mm,
        yt1 = df.yt1 * mm,
        yt2 = df.yt2 * mm,

        z1  = df.z1  * mm,
        z2  = df.z2  * mm,
        zb1 = df.zb1 * mm,
        zb2 = df.zb2 * mm,
        zr1 = df.zr1 * mm,
        zr2 = df.zr2 * mm,
        zs  = df.zs  * mm,
        zt1 = df.zt1 * mm,
        zt2 = df.zt2 * mm,
    )
    else
        return nothing
    end
end
