### --------------------------------------------------------------------- ###
# --------------------  dbRDA Wrapper /wo lingoes correction ---------------#
### --------------------------------------------------------------------- ###

#FUNCTION: Runs a dbRDA on a set of communities defined in the script that calls this function.

#COMMENT: In the first version of the submitted MS dbRDA was calculated with the
#Lingoes correction (Lingoes, 1971) for negative eigenvalues. One of the
#reviewers pointed out that McArdle and Anderson (2001) showed that correction
#was not necessary. Hence I redid the analysis without corrections.

# Lingoes, J. C. (1971). Some boundary conditions for a monotone analysis of
# symmetric matrices. Psychometrika, 36(2):195-203.

# McArdle, B. H., & Anderson, M. J. (2001). Fitting multivariate models to
# community data: a comment on distance-based redundancy analysis. Ecology,
# 82(1), 290-297.


dbrda.wrapper <- function(Model, warn = F, comwd, SEEDS) {
   output <- list()
   # SETUP
   setwd(comwd)
   if (warn)
      options(warn = 0)
   if (!warn)
      options(warn = -1)
   for (seed.i in SEEDS) {
      set.seed(seed.i)
      setwd(comwd)
      source(Model)
      data <- Simulation.output$data
      nmax <- ncol(data)
      sp.data <- data[, 1:9]
      var.data <- scale(data[, 10:nmax]) %>% as.data.frame()
      
      # remove emtpy rows, i.e. sites
      index <- apply(sp.data, 1, sum) > 0
      sp.data <- sp.data[index, ]
      var.data <- var.data[index, ]
      
      # run model
      mod <-
         dbrda(sp.data ~ .,
               data = var.data,
               #add = "lingoes",
               distance = "bray")
      
      # prepare output
      anv1.time <-
         system.time(anv1 <-
                        anova.cca(
                           mod,
                           step  = 1000,
                           by = "margin",
                           parallel = 2#parallel::detectCores() - 2
                        ))
      # anv2.time <-
      #    system.time(anv2 <-
      #                   anova.cca(
      #                      mod,
      #                      step  = 1000,
      #                      by = "axis",
      #                      parallel = parallel::detectCores() - 2,
      #                      type = "margin"
      #                   ))
      mod.sum <- summary(mod)
      #statements
      p1 <- c(
         round(mod$CCA$tot.chi / mod$tot.chi * 100),
         round(sum(mod$CCA$eig[1:2]) / mod$CCA$tot.chi * 100),
         round(sum(mod$CCA$eig[1:2]) / mod$tot.chi * 100)
      )
      
      output[[seed.i]] <- list(
         "By Terms" = as.matrix(anv1),
         # "By Axis"  = as.matrix(anv2),
         "Biplot Scores" = mod.sum$biplot,
         "Importance of components" = mod.sum$cont,
         "Variance Expplained" = p1,
         "Response" = Simulation.output$Response.Type,
         "Samples" = Simulation.output$Samples,
         "Times" = anv1.time[[1]]
      )
   }
   ## Output
   return(output)
   
   
   
}