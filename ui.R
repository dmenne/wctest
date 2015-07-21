library(shinyAce)
library(shinyjs)

shinyUI(fluidPage(
  useShinyjs(),
  titlePanel("Ungepaarter Wilcoxon-Test (Mann-Whitney U-Test) nach Gruppen"),
  sidebarLayout(
    sidebarPanel( "",
      actionButton("computeButton","Berechnen"),
      actionButton("clearButton","Löschen"),
      textOutput("summary"),
      imageOutput("helpImage")
    ),
    mainPanel("Daten: Zweispaltige Excel-Daten aus der Zwischenablage mit STRG-V hier eingeben",
      aceEditor("data", "", mode = "plain_text"),
      wellPanel(id = "results",
        tags$script(type = "text/javascript",
          HTML("ace.edit('data').setOptions({tabSize:12,showInvisibles:true,useSoftTabs:false});")),
        plotOutput("diffplot"),
        HTML("<ul><li>Wenn eine der Konfidenzbalken den Wert 0 NICHT kreuzt, ist diese Differenz signifikant von Null verschieden mit p<0.05.</li><li>Wenn alle Balken den Wert 0 kreuzen, wurde kein signifikanter Effekt gefunden. Das heißt aber nicht, dass keine Unterschied vorhanden ist, er ist nur mit diesen Daten nicht nachweisbar.</li><li>p-Werte werden hier bewusst nicht ausgegeben, da die Konfidenzintervalle aussagekräftiger sind.</li></ul>"),
        DT::dataTableOutput('table')
      )

    )
  )
))

