library(pairwiseCI)
library(DT)
library(stringr)
library(ggplot2)
library(dplyr)

shinyServer(function(input, output, session) {
  hide("results")
  theme_set(theme_bw())

  getData = reactive({
    data = input$data
    # Replace multiple spaces or tabs by single tab
    data = str_replace_all(data,"[ ]","")
    data = str_replace_all(data,"([\t]+)","\t")
    data = str_replace_all(data,",",".")
    if (nchar(data) < 10) return(NULL)
    d = na.omit(read.table(textConnection(data), sep = "\t", header = TRUE))
    d = droplevels(d)
    if (nrow(d) < 3) return(NULL)
    attr(d,"par") = ""
    # if there is only one column, add a group name
    if (ncol(d) == 1) {
      d = cbind(group = "A", d)
      hide("results")
    } else {
      d[,1] = as.factor(d[,1])
      if (nlevels(d[,1]) == 1) hide("results") else show("results")
    }
    if (ncol(d) == 3) {
      d[,2]  = d[,3] - d[,2]
      attr(d,"par") = paste(names(d)[3], names(d)[2], sep = " - ")
      names(d)[2] = paste("diff", names(d)[3], names(d)[2], sep = "_")
      d[,3] = NULL
    }
    d
  })

  pc = reactive({
    d = getData();
    if (is.null(d)) return(NULL)
    form = as.formula(paste0(names(d)[2],"~",names(d)[1]))
    td = table(d[,1])
    t1 = which(as.vector(td) == 1)
    if (length(t1) > 0 ) {
      stop("Nur ein Element in Gruppe '", names(td)[t1[1]],"'")
    }
    if (length(td) == 1) {
      if (input$test_type == "Wilcoxon") {
        p = wilcox.test(d[,2], exact = FALSE, conf.int = TRUE)
        attr(p, "summary") = paste0("<b>Einstichproben Wilcoxon-Test</b><br>",
              nrow(d), " Werte in einer Gruppe. <br>p=",
               signif(p$p.value,2)," im Test gegen 0.<br>Schätzwert: ",
              signif(p$estimate,2), "<br>95% Konfidenzintervall: (",
              signif(p$conf.int[1],2), "...",signif(p$conf.int[2],2),")")
      } else {
        p = t.test(d[,2])
        attr(p, "summary") = paste0("<b>Einstichproben t-Test</b><br>",
                  nrow(d), " Werte in einer Gruppe. <br>p=",
                  signif(p$p.value,2)," im Test gegen 0.<br>Schätzwert: ",
                  signif(p$estimate,2), "<br>95% Konfidenzintervall: (",
                  signif(p$conf.int[1],2), "...",signif(p$conf.int[2],2),")")
      }
    } else {
      method = ifelse(input$test_type == "Wilcoxon", "HL.diff", "Param.diff")
      p = pairwiseCI(form, d, method = method)
      attr(p, "summary") = paste(nrow(d), " gültige Werte in ",
            length(td)," Gruppen", paste(names(td), collapse = ", "))
    }
    attr(p,"par") = attr(d,"par")
    p
  })

  output$summary = renderText({
    if (is.null(pc())) return(NULL)
    show("summary")
    attr(pc(),"summary")
  }
  )

  observe({
    if (input$clearButton == 0)
      return(NULL)
    hide("results")
    hide("summary")
    # Dirty trick to clear using an invalid value
    updateAceEditor(session, "data",  1)
  })

  observe({
    if (input$sampleButton == 0)
      return(NULL)
    # Create simulated data
    ngroups = 3
    npergroup = 15
    d = data.frame(Behandlung = rep(letters[1:ngroups], each = npergroup),
           Wert = 0.5 + round(rt(npergroup*ngroups, df = 2,
                           ncp = rep(1:ngroups, each = npergroup)),2))
    write.table(d, file = textConnection("d1","w"),
                row.names = FALSE, sep = "\t", quote = FALSE)
    d1 = paste(d1, collapse = "\n")
    updateAceEditor(session, "data", d1)
  })

  observe({
    if (input$sampleDiffButton == 0)
      return(NULL)
    # Create simulated data
    ngroups = 3
    npergroup = 15
    d = data.frame(Behandlung = rep(letters[1:ngroups], each = npergroup),
                   Vorher = round(rt(npergroup*ngroups, df = 3,
                                   ncp = rep(1:ngroups, each = npergroup)),2))
    d$Nachher = round(d$Vorher + rlnorm(nrow(d),0,1),2) + 0.5 * as.integer(d$Behandlung)
    write.table(d, file = textConnection("d1","w"),
                row.names = FALSE, sep = "\t", quote = FALSE)
    d1 = paste(d1, collapse = "\n")
    updateAceEditor(session, "data", d1)
  })

  output$helpImage = renderImage({
    list(src = normalizePath("wctesthelp.png"), alt = "How to use")
  }, deleteFile = FALSE)

  output$diffplot = renderPlot({
    p = pc()
    if (is.null(p) | class(p) == "htest") return(NULL)
    ylim = c(0, length(p$byout[[1]][[1]]) + 1)
    show("results")
    main = paste("95% Konfidenzintervalle", attr(p,"par") )
    plotCI(p, main = main, HL = TRUE, lines = 0, ylim = ylim)
  })

  output$boxplot = renderPlot({
    d = getData()
    if (is.null(d) ) return(NULL)
    aspect.ratio = length(unique(d[[1]]))/1.5
    ggplot(d, aes_string(x = names(d)[1], y = names(d)[2])) +
      geom_boxplot( ) +
      theme(aspect.ratio = aspect.ratio)
  })

  output$boxplot1 = renderPlot({
    d = getData()
    if (is.null(d) ) return(NULL)
    aspect.ratio = length(unique(d[[1]]))/1.5
    ylim = quantile(d[,2],c(0.05,0.95))
    ggplot(d, aes_string(x = names(d)[1], y = names(d)[2])) +
      geom_boxplot( ) +
      scale_y_continuous(limits = ylim) +
      theme(aspect.ratio = aspect.ratio)
  })

  output$box_table = renderDT({
    d = getData()
    if (is.null(d)) return(NULL)
    g = names(d)[1]
    q25 = function(x) signif(quantile(x, 0.25),2)
    q75 = function(x) signif(quantile(x, 0.75),2)
    med = function(x) signif(median(x),2)
    d %>% group_by_(g) %>%
      summarize_all(
        .funs = c(med = med, q25 = q25, q75 = q75)
      )
  },
  extensions = "Buttons",
  rownames = FALSE,
  options = list(paging = FALSE, searching = FALSE,
                   autoWidth = TRUE,
                   dom = 'Bfrtip',
                   buttons = c('excel', 'copy', "csv"))
  )


  output$table = renderDT({
      if (is.null(pc()) ) return(NULL)
      p = as.data.frame(pc())
      p = cbind(Vergleich =  p[,4], signif(p[,1:3],3))
    },
    extensions = "Buttons",
    rownames = FALSE,
    options = list(paging = FALSE, searching = FALSE,
                  autoWidth = TRUE,
                  dom = 'Bfrtip',
                  buttons = c('excel', 'copy', "csv"))
  )
})

