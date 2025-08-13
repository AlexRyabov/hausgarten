
function f_plotResidualsmy(mdl)
clf
nexttile
plotResiduals(mdl, "histogram")
nexttile
plotResiduals(mdl, "probability")
nexttile
plotResiduals(mdl, "fitted")
