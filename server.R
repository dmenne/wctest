library(pairwiseCI)
library(DT)
library(stringr)
library(ggplot2)

shinyServer(function(input, output, session) {
  hide("results")
  theme_set(theme_bw())

  getData = reactive({
    data = input$data
    # Replace multiple spaces or tabs by single tab
    data = str_replace_all(data,"([\t ]+)","\t")
    data = str_replace_all(data,",",".")
    if (nchar(data) < 10) return(NULL)
    d = na.omit(read.table(textConnection(data), sep = "\t", header = TRUE))
    if (nrow(d) < 3) return(NULL)
    # if there is only one column, add a group name
    if (ncol(d) == 1) {
      d = cbind(group = "A", d)
      hide("results")
    } else {
      d[,1] = as.factor(d[,1])
      show("results")
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
      p = wilcox.test(d[,2], exact = FALSE, conf.int = TRUE)
      attr(p, "summary") = paste0("<b>Einstichproben Wilcoxon-Test</b><br>",
            nrow(d), " Werte in einer Gruppe. <br>p=",
             signif(p$p.value,2)," im Test gegen 0.<br>Schätzwert: ",
            signif(p$estimate,2), "<br>95% Konfidenzintervall: (",
            signif(p$conf.int[1],2), "...",signif(p$conf.int[2],2),")"
        )
    } else {
      p = pairwiseCI(form, d, method = "Param.diff")
      attr(p, "summary") = paste(nrow(d), " gültige Werte in ",
            length(td)," Gruppen", paste(names(td), collapse = ", "))
    }
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
    updateAceEditor(session, "data",value = 1)
  })

  observe({
    if (input$sampleButton == 0)
      return(NULL)
    # Create simulated data
    ngroups = 3
    npergroup = 15
    d = data.frame(Behandlung = rep(letters[1:ngroups], each = npergroup),
           Wert = round(rt(npergroup*ngroups, df = 2,
                           ncp = rep(1:ngroups, each = npergroup)),2))
    write.table(d, file = textConnection("d1","w"),
                row.names = FALSE, sep = "\t", quote = FALSE)
    d1 = paste(d1, collapse = "\n")
    updateAceEditor(session, "data",value = d1)
  })

    output$helpImage = renderImage({
    list(src = normalizePath("wctesthelp.png"), alt = "How to use")
  }, deleteFile = FALSE)

  output$diffplot = renderPlot({
    p = pc()
    if (is.null(p) | class(p) == "htest") return(NULL)
    ylim = c(0, length(p$byout[[1]][[1]]) + 1)
    show("results")

    plotCI(p, main = "95% Konfidenzintervalle", HL = TRUE, lines = 0, ylim = ylim)
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
      scale_y_continuous(limits=ylim) +
      theme(aspect.ratio = aspect.ratio)
  })

    output$table = DT::renderDataTable({
    if (is.null(pc())| class(p) == "htest") return(NULL)
    as.data.frame(pc())},
      options = list(dom = 't'))
})

