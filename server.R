library(pairwiseCI)
library(DT)
shinyServer(function(input, output, session) {
  d = NULL
  pc = NULL
  output$results = renderText({
    if (input$computeButton == 0)
      return(NULL)
    data = isolate(input$data)
    if (nchar(data) < 5) return(NULL)
    d <<- na.omit(read.table(textConnection(data), sep = "\t", header = TRUE))
    d[,1] <<- as.factor(d[,1])

    form = as.formula(paste0(names(d)[2],"~",names(d)[1]))
    pc <<- pairwiseCI(form, d, method = "Param.diff")
    paste(nrow(as.data.frame(d)), " vollständige Werte.")
  })
  observe({
    if (input$clearButton == 0)
      return(NULL)
    updateAceEditor(session, "data",value = "\n")
  })

  output$helpImage = renderImage({
    list(src = normalizePath("wctesthelp.png"), alt = "How to use")
  }, deleteFile = FALSE)

  output$diffplot = renderPlot({
    input$computeButton
    if (is.null(pc)) return(NULL)
    par(oma = c(6,0,0,0))
    plot(pc, main = "95% Konfidenzintervalle")
    mtext("Wenn einer der Balken den Wert 0 NICHT kreuzt, ist die Differenz\nsignifikant von Null verschieden mit p < 0.05.\nWenn alle Balken den Wert 0 kreuzen, kann ein signifikanter Effekt nicht festgestellt werden.\nDie geliebten p-Werte werden hier bewusst nicht ausgegeben,\nda die Konfidenzintervalle aussagekräftiger sind.",1, adj = 0, padj = 2)
  })

    output$table = DT::renderDataTable({
      input$computeButton
      if (is.null(pc)) return(NULL)
      as.data.frame(pc)
    },
    options = list(autoWidth = TRUE, dom = 't'))
})

