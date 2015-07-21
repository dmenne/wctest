library(pairwiseCI)
library(DT)
library(stringr)

shinyServer(function(input, output, session) {
  hide("results")

  pc = reactive({
    if (input$computeButton == 0)
      return(NULL)
    data = isolate(input$data)
    if (nchar(data) < 5) return(NULL)
    # Replace multiple spaces or tabs by single tab
    data = str_replace_all(data,"([\t ]+)","\t")
    d = na.omit(read.table(textConnection(data), sep = "\t", header = TRUE))
    d[,1] = as.factor(d[,1])

    form = as.formula(paste0(names(d)[2],"~",names(d)[1]))
    td = table(d[,1])
    t1 = which(as.vector(td) == 1)
    if (length(t1) > 0 ) {
      stop("Nur ein Element in Gruppe '", names(td)[t1[1]],"'")
    }
    p = pairwiseCI(form, d, method = "Param.diff")
    attr(p, "summary") = paste(nrow(d), " gültige Werte")
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

