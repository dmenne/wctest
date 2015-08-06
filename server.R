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
    if (nchar(data) < 10) return(NULL)
    d = na.omit(read.table(textConnection(data), sep = "\t", header = TRUE))
    if (nrow(d) < 3) return(NULL)
    d[,1] = as.factor(d[,1])
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
    if (length(td) == 1){
      p = wilcox.test(d[,2], exact = FALSE)
      attr(p, "summary") = paste(nrow(d),
            " Werte in nur einer Gruppe. p=",
             signif(p$p.value,2)," im Test gegen 0.")
    } else {
      p = pairwiseCI(form, d, method = "Param.diff")
      attr(p, "summary") = paste(nrow(d), " gültige Werte in ", length(td)," Gruppen",
                               paste(names(td), collapse = ", "))
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
    updateAceEditor(session, "data",value = "\n")
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
    ggplot(d, aes_string(x = names(d)[1], y = names(d)[2])) +
      geom_boxplot( )
  })


  output$table = DT::renderDataTable({
    if (is.null(pc())| class(p) == "htest") return(NULL)
    as.data.frame(pc())},
      options = list(dom = 't'))
})

