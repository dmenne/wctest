library(shinyAce)
library(shinyjs)

shinyUI(fluidPage(
  useShinyjs(),
  tags$style(HTML("ul{margin-left:-30px}")),
  titlePanel("Boxplot und ungepaarter Wilcoxon-Test (Mann-Whitney U-Test) nach Gruppen"),
  sidebarLayout(
    sidebarPanel( "",
      htmlOutput("summary"),
      imageOutput("helpImage", height = "430px"),
      HTML("<ul><li>Kopieren Sie die Spalten wie oben in eine extra Seite von Excel.</li><li>In der ersten Spalte steht der Gruppenname, am besten als Textkürzel; in der zweiten die gemessenen Werten.</li><li>Spaltenüberschriften müssen vorhanden sein.</li><li>Nehmen Sie die Daten mit Spaltenüberschriften in die Zwischenablage (Strg-C)</li><li>Pasten Sie die Daten in das Feld oben rechts (Strg-V).</li><li>Sie können auch nur eine Spalte <b>mit Spaltenüberschrift</b>  eingeben. Dann wird ein Einstichproben-Wilcoxon-Test ausgeführt, es wird also die Nullhypothese getestet, dass die Werte aus einer Stichprobe stammt, die nicht gegen Null verschoben ist.</li></ul>"),
    helpText(a("Source on github", href = "https://github.com/dmenne/wctest", target = "_blank"))
    ),
    mainPanel("Daten: Zweispaltige Excel-Daten aus der Zwischenablage mit STRG-V hier eingeben",
      aceEditor("data", "", mode = "plain_text"),
      actionButton("clearButton","Löschen", icon = icon("eraser")),
      actionButton("sampleButton","Beispiel", icon = icon("eyedropper")),
      helpText("Bevor Sie Ihre eigenen Daten auswerten, erzeugen Sie bitte durch Klick auf die Schaltfläche 'Beispiel' simulierte Daten eines Experiments, und versuchen Sie, das Ergebnis zu interpretieren. Klicken Sie nochmal und interpretieren Sie das Experiment wieder. Mehrfaches Klicken simuliert, wie die Daten der gleichen (ja!!) Studie bei mehrfachen Wiederholungen herauskommen könnten. Vielleicht interpretieren Sie nach dieser Erfahrung Ihre Studienergebnisse etwas weniger dogmatisch."),
      wellPanel(id = "results",
        tags$script(type = "text/javascript",
          HTML("ace.edit('data').setOptions({tabSize:12,showInvisibles:true,useSoftTabs:false});")),
        plotOutput("diffplot"),
        HTML("<ul><li>Jeder Balken repräsentiert das 95%-Konfidenzintervale einer paarweisen Gruppendifferenz.</li><li>Wenn eine der Konfidenzbalken den Wert 0 NICHT kreuzt, ist diese Differenz signifikant von Null verschieden mit p<0.05.</li><li>Wenn alle Balken den Wert 0 kreuzen, wurde für keine Differenz ein signifikanter Effekt gefunden. Das heißt aber nicht, dass kein Unterschiede zwischen den Gruppen vorhanden sind, diese sind nur mit den Daten nicht nachweisbar.</li><li>p-Werte werden hier bewusst nicht ausgegeben, da die Konfidenzintervalle aussagekräftiger sind.</li><li>Eine Korrektur für multiples Testen - Stichwort: Bonferroni - wurde nicht durchgeführt.<li>Um die Graphik zu speichern, verwenden Sie im Browser das Menü, das nach Rechtsklick erscheint.</li><li>In der Tabelle unten ist 'estimate' die geschätzte Differenz für den Paarvergleich (difference in location): 'lower' und 'upper' sind die 95% Konfidenzgrenzen.</li><li>Falls Sie die Werte dieser Tabelle in Ihre Arbeit übernehmen, reduzieren Sie bitte die Anzahl Kommastellen einheitlich; in der hier wiedergegebenen Tabelle sind es zu viele!</li></ul>"),
        DT::dataTableOutput('table'),
        plotOutput("boxplot"),
        HTML("<ul><li>Im unten stehende Diagramm ist die vertikale Achse gespreizt. Es kann sein, dass einige Ausreißer deshalb nicht sichtbar sind, aber der zentrale Bereich deutlicher dargestellt wird.</li></ul>"),
        plotOutput("boxplot1"),
        HTML("<ul><li>Im Box-Whiskers-Plot werden Mediane, Quartile und Ausreißer (outliers) dargestellt. Siehe den Artikel in <a href='https://de.wikipedia.org/wiki/Boxplot'>Wikipedia</a>.</li><li>Um die Graphik zu speichern, verwenden Sie im Browser das Menü, das nach Rechtsklick erscheint.</li></ul>"),
        plotOutput("histogram1"),
        plotOutput("density")
      ) # wellPanel
    )
  )
))

