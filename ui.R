library(shinyAce)
library(shinyjs)

shinyUI(fluidPage(
  useShinyjs(),
  tags$style(HTML("ul{margin-left:-30px}")),
  titlePanel("Boxplot und ungepaarter Wilcoxon-Test (Mann-Whitney U-Test) nach Gruppen"),
  sidebarLayout(
    sidebarPanel( "",
      textOutput("summary"),
      imageOutput("helpImage", height = "430px"),
      HTML("<ul><li>Kopieren Sie die Spalten wie oben in eine extra Seite von Excel.</li><li>In der ersten Spalte steht der Gruppenname, am besten als Textkürzel; in der zweiten die gemessenen Werten.</li><li>Spaltenüberschriften müssen vorhanden sein.</li><li>Nehmen Sie die Daten mit Spaltenüberschriften in die Zwischenablage (STRG-C)</li><li>Pasten Sie die Daten in das Feld oben rechts.</li></ul>")
    ),
    mainPanel("Daten: Zweispaltige Excel-Daten aus der Zwischenablage mit STRG-V hier eingeben",
      aceEditor("data", "", mode = "plain_text"),
      actionButton("clearButton","Löschen"),
      wellPanel(id = "results",
        tags$script(type = "text/javascript",
          HTML("ace.edit('data').setOptions({tabSize:12,showInvisibles:true,useSoftTabs:false});")),
        plotOutput("diffplot"),
        HTML("<ul><li>Wenn eine der Konfidenzbalken den Wert 0 NICHT kreuzt, ist diese Differenz signifikant von Null verschieden mit p<0.05.</li><li>Wenn alle Balken den Wert 0 kreuzen, wurde kein signifikanter Effekt gefunden. Das heißt aber nicht, dass keine Unterschied vorhanden ist, er ist nur mit diesen Daten nicht nachweisbar.</li><li>p-Werte werden hier bewusst nicht ausgegeben, da die Konfidenzintervalle aussagekräftiger sind.</li><li>Eine Korrektur für multiples Testen - Stichwort: Bonferroni - wurde nicht durchgeführt.<li>Um die Graphik zu speichern, verwenden Sie im Browser das Menü, das nach Rechtsklick erscheint.</li></ul>"),
        DT::dataTableOutput('table'),
        plotOutput("boxplot"),
        HTML("<ul><li>Im Box-Whiskers-Plot werden Mediane, Quartile und Ausreißer (outliers) dargestellt. Siehe den Artikel in <a href='https://de.wikipedia.org/wiki/Boxplot'>Wikipedia</a>.</li><li>Um die Graphik zu speichern, verwenden Sie im Browser das Menü, das nach Rechtsklick erscheint.</li></ul>")
      ) # wellPanel
    )
  )
))

