library(pairwiseCI)
library(DT)
shinyServer(function(input, output, session) {
  hide("results")

  pc = reactive({
    if (input$computeButton == 0)
      return(NULL)
    data = isolate(input$data)
    if (nchar(data) < 5) return(NULL)
    d = na.omit(read.table(textConnection(data), sep = "\t", header = TRUE))
    d[,1] = as.factor(d[,1])

    form = as.formula(paste0(names(d)[2],"~",names(d)[1]))
    p = pairwiseCI(form, d, method = "Param.diff")
    attr(p, "nrow") = nrow(d)
    p
  })

  output$summary = renderText({
    if (is.null(pc())) return(NULL)
    show("summary")
    paste(attr(pc(),"nrow"), "valid values")
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
    if (is.null(p)) return(NULL)
    ylim = c(0, length(p$byout[[1]][[1]]) + 1)
    show("results")

    plotCI(p, main = "95% Konfidenzintervalle", HL = TRUE, lines = 0, ylim = ylim)
  })


  output$table = DT::renderDataTable({
    if (is.null(pc())) return(NULL)
    as.data.frame(pc())},
      options = list(autoWidth = TRUE, dom = 't'))
})

