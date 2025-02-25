### -------------------- ###
# --- FPR and FNR plot --- #
### -------------------- ### 

# Jonathan Jupke 
# date unknown
# Should ecologist prefer model- over algorithm-based methods?

# This plots shows the creation of Figure 3 in the paper which shows the false
# positive and negative rates of all four methods at different significance
# levels.

## -- OVERVIEW -- ## 
# 01. Setup
# 02. Calculate FPR and FNR
# 03. Create Plot
# ---------------- #

# 01. Setup -------------------------------------------------------------------

pacman::p_load(
               dplyr,
               ggplot2,
               ggthemes, # for base theme
               cowplot, # ggdraw for annotations
               ggstance, # vertical dodging
               wesanderson, # color palette,
               data.table
)
# also required: here

setwd("~/01_Uni/My Papers/1909_Should ecologists prefer model- over algorithm-based multivariate methods/r_scripts/reviewer_comments/03_analyse_results/")
dat = readRDS("vac_all_results.RDS")

# color palette
mycol = wes_palette("Zissou1")

dat[, method2 := ifelse(transformation == "NA", method, paste0(method,"_",transformation))]
dat[, method := method2]

# 02. Calculate FPR and FNR  --------------------------------------------------

FPR = data.table(FPR = rep(0, 35),
                 method = rep("empty", 35),
                 sig.lvl = rep(0, 35))
FNR = data.table(FNR = rep(0, 35),
                 method = rep("empty", 35),
                 sig.lvl = rep(0, 35))


method.vec = unique(dat$method2)
siglevels = c(0.01, 0.03, 0.05, 0.07, 0.1)
for (i in 0:6) {
      
      methods = method.vec[i + 1] 
      dat2 = dat[method2 == methods]
      
      for (k in 1:5) {
            
            alpha = siglevels[k]
            FP = ifelse(
                  alpha == 0.01, 
                  dat2[,sum(false.positive.01)],
                  ifelse(
                        alpha == 0.03,
                        dat2[,sum(false.positive.03)],
                        ifelse(
                              alpha == 0.05,
                              dat2[,sum(false.positive.05)],
                              ifelse(
                                    alpha == 0.07,
                                    dat2[,sum(false.positive.07)],
                                    dat2[,sum(false.positive.1)]
                              )
                        )
                  )

            )
            FN = ifelse(
                  alpha == 0.01, 
                  dat2[,sum(false.negative.01)],
                  ifelse(
                        alpha == 0.03,
                        dat2[,sum(false.negative.03)],
                        ifelse(
                              alpha == 0.05,
                              dat2[,sum(false.negative.05)],
                              ifelse(
                                    alpha == 0.07,
                                    dat2[,sum(false.negative.07)],
                                    dat2[,sum(false.negative.1)]
                              )
                        )
                  )
                  
            )
            TN = dat2[variable == "Noise" & p.value > alpha] %>% nrow()
            TP = dat2[variable %like% "env1" & p.value <= alpha] %>% nrow()
            FPR.var =  FP/(TN + FP)
            FNR.var = FN/(TP + FN)
            FPR[i * 5 + k, c("FPR", "method", "sig.lvl") := .(FPR.var, methods, alpha)]
            FNR[i * 5 + k, c("FNR", "method", "sig.lvl") := .(FNR.var, methods, alpha)]
            
      }
      
      
}


FPR %>% setDT
FNR %>% setDT

FPR[method == "mvglm", method := "MvGLM"]
FNR[method == "mvglm", method := "MvGLM"]
FNR[method == "dbRDA_no transformation", method := "dbRDA"]
FPR[method == "dbRDA_no transformation", method := "dbRDA"]
FPR[method == "CCA_SQRT", method := "CCA_sqrt"]
FNR[method == "CCA_SQRT", method := "CCA_sqrt"]
FNR[method == "CCA_no_transformation", method := "CCA"]
FPR[method == "CCA_no_transformation", method := "CCA"]
FNR[method == "CCA_LOG", method := "CCA_log"]
FPR[method == "CCA_LOG", method := "CCA_log"]

saveRDS(FNR, "../../../result_data/06_false_negative_and_positive_rates/FNR_typeIII.RDS")
saveRDS(FPR, "../../../result_data/06_false_negative_and_positive_rates/FPR_typeIII.RDS")


# 03. Create Plot  ------------------------------------------------------------


FPR

fpr_plot2 = ggplot(data = FPR, aes(x = sig.lvl, y = FPR)) + 
      scale_fill_brewer( type = "qual", palette = 3, direction = 1,
                          aesthetics = "fill") + 
      scale_colour_brewer( type = "qual", palette = 3, direction = 1,
                          aesthetics = "colour") + 
      geom_line(aes(col = method), size = 1, alpha = 1) + 
      geom_point(aes(fill = method), shape = 21, size = 3) + 
      ylab(label = "False Positive Rate") +
      xlab(label = "Significance level") + 
      ylim(0, 0.58) +
      theme_minimal_hgrid() + 
      theme(
            axis.title.x = element_text(size = 15),
            legend.title = element_blank(),
            legend.position = "none",
            axis.title.y = element_blank()
      )

fnr_plot2 = ggplot(data = FNR, aes(x = sig.lvl, y = FNR)) +
      scale_fill_brewer( type = "qual", palette = 3, direction = 1,
                         aesthetics = "fill") + 
      scale_colour_brewer( type = "qual", palette = 3, direction = 1,
                           aesthetics = "colour") + 
      geom_line(aes(col = method), size = 1, alpha = 1, show.legend = F) + 
      geom_point(aes(fill = method), shape = 21, size = 3) + 
      ylab(label = "False Negative Rate") +
      xlab(label = "Significance level") + 
      ylim(0, 0.58) + 
      theme_minimal_hgrid() + 
      theme(
            axis.title.x = element_text(size = 15),
            legend.title = element_blank(),
            legend.position = "none",
            axis.title.y = element_blank()
            
      )

fnr_plot2_legend = ggplot(data = FNR, aes(x = sig.lvl, y = FNR)) +
      scale_fill_brewer( type = "qual", palette = 3, direction = 1,
                         aesthetics = "fill") + 
      scale_colour_brewer( type = "qual", palette = 3, direction = 1,
                           aesthetics = "colour") + 
      geom_line(aes(col = method), size = 1, alpha = 1, show.legend = F) + 
      geom_point(aes(fill = method), shape = 21, size = 3) + 
      ylab(label = "False Negative Rate") +
      xlab(label = "Significance level") + 
      ylim(0, 0.58) + 
      theme_minimal_hgrid() + 
      theme(
            axis.title.x = element_text(size = 15),
            legend.title = element_blank(),
            
            axis.title.y = element_blank()
            
      )

test = cowplot::get_legend(fnr_plot2_legend)

(both = plot_grid(fpr_plot, 
                  fnr_plot, 
                  rel_widths = c(1,1.4),
                  scale = c(.9, .9),
                  labels = c("False Positive Rate", "False Negative Rate"))
)


# 04. Save Plot --------------------------------------------------------------

# ggplot2::ggsave(plot = both,
#                 filename = "../../../plots/FPNR_vac.pdf",
#                 height = 10,
#                 width = 20,
#                 units = "cm")

