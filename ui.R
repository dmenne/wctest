library(shinyAce)
library(shinyjs)
library(DT)

shinyUI(fluidPage(
  useShinyjs(),
  tags$style(HTML("ul{margin-left:-30px}")),
  tags$style(HTML("hr{border-color: #e4e4e4 #a4a4a4;border-width: 6px;margin-top:1em;margin-bottom:0.5em;}")),
  titlePanel("Vertrauensintervall zwischen Gruppen: Wilcoxon und t-Test"),
  sidebarLayout(
    sidebarPanel(
      "",
      radioButtons("test_type", NULL, c("Wilcoxon", "t-test")),
      htmlOutput("summary"),
      imageOutput("helpImage", height = "430px"),
      HTML(
        '<ul><li>Kopieren Sie die Spalten wie oben in eine extra Seite von Excel.</li><li>In der ersten Spalte steht der Gruppenname, am besten als Textkürzel; in der zweiten die gemessenen Werten.</li><li>Spaltenüberschriften müssen vorhanden sein.</li><li>Nehmen Sie die Daten mit Spaltenüberschriften in die Zwischenablage (Strg-C)</li><li>Pasten Sie die Daten in das Feld oben rechts (Strg-V).</li><li>Sie können auch nur <b>eine Spalte</b> mit Spaltenüberschrift eingeben. Dann wird ein Einstichproben-Wilcoxon-Test ausgeführt, es wird also die Nullhypothese getestet, dass die Werte aus einer Stichprobe stammen, die nicht gegen Null verschoben sind.</li><li>Wenn Sie Daten mit <b>drei</b> Spalten eingeben, dann wird die Differenz von Spalte 3 zu Spalte 4 gebildet und ein Tests zwischen den Gruppen ausgeführt; dieser Fall ist <a href = "https://menne-biomed.de/blog/vorher-nachher-studie-excel">hier</a> beschrieben. Ein Beispiel erhalten Sie, wenn Sie den Button <i>Beispiel Diff</i> klicken.</li></ul>'
      ),
      helpText(
        a("Source on github", href = "https://github.com/dmenne/wctest", target = "_blank")
      ),
      helpText("Version 2018_02_22_01")
    ),
    # end sidebarpanel
    mainPanel(
      "Excel-Daten mit 1, 2 oder 3 Spalten in der Zwischenablage mit STRG-V hier eingeben",
      aceEditor("data", "", mode = "plain_text"),
      actionButton("clearButton", "Löschen", icon = icon("eraser")),
      actionButton("sampleButton", "Beispiel", icon = icon("eyedropper")),
      actionButton("sampleDiffButton", "Beispiel Diff", icon = icon("eyedropper")),
      helpText(
        "Bevor Sie Ihre eigenen Daten auswerten, erzeugen Sie bitte durch Klick auf die Schaltfläche 'Beispiel' simulierte Daten eines Experiments. Versuchen Sie, das Ergebnis zu interpretieren. Klicken Sie dann noch einmal und interpretieren Sie das Experiment wieder. Mehrfaches Klicken simuliert, wie die Daten der gleichen Studie bei mehrfachen Wiederholungen herauskommen könnten. Wenn Sie nur auf Signifikanzen schielen, werden Sie entsetzt sein, wie unterschiedlich die Ergebnisse sind. Die Breite der Intervalle, also die Vertrauensbereiche, variieren dagegen nicht so stark. Glauben Sie also nie blind an 'signifikante Ergebnisse', schauen Sie auf Vertrauensintervalle und damit auf Effektgrößen."
      ),
      wellPanel(
        id = "results",
        tags$script(
          type = "text/javascript",
          HTML(
            "ace.edit('data').setOptions({tabSize:12,showInvisibles:true,useSoftTabs:false});"
          )
        ),
        plotOutput("diffplot"),
        HTML(
          '<ul><li>Jeder Balken repräsentiert das 95%-Konfidenzintervall einer Gruppendifferenz.</li><li>Wenn ein Konfidenzbalken den Wert 0 NICHT kreuzt, ist diese Differenz signifikant von Null verschieden mit p<0.05.</li><li>Wenn ein Balken den Wert 0  kreuzt, dann ist die Differenz für dieses Paar signifkant von Null verschieden. Schreiben Sie bitte nicht: "Beide Behandlungsmethoden haben die gleiche Wirkung auf ...", sondern etwa: "Mit den Daten konnte ein Unterschied zwischen den beiden Behandlungsmethoden nicht nachgewiesen werden"; in Gedanken: ein Unterschied könnnte aber duchaus bestehen.</li><li>Wenn alle Balken den Wert 0 kreuzen, wurde für keine Paarung ein signifikanter Unterschied gefunden. </li><li>p-Werte werden hier bewusst nicht ausgegeben, da die Konfidenzintervalle aussagekräftiger sind.</li><li>Eine Korrektur für multiples Testen - Stichwort: Bonferroni - wurde nicht durchgeführt.<li>Um die Graphik zu speichern, verwenden Sie im Browser das Menü, das nach Rechtsklick erscheint.</li><li>In der Tabelle unten ist "estimate" die geschätzte Differenz für den Paarvergleich; "lower" und "upper" sind die 95% Konfidenzgrenzen. Für den Wilcoxon-Test ist es die "difference in location", bestimmt mit dem <a href="https://en.wikipedia.org/wiki/Hodges%E2%80%93Lehmann_estimator">Hodges-Lehman Schätzer</a>; näherungsweise ist dies die Differenz der Mediane. Für den t-Test ist es die Differenz der Mittelwerte und deren Konfidenzintervall, unter der Annahme ungleicher Varianzen.</li></ul>'
        ),
        DTOutput('table'),
        HTML("<i>Zum Einfügen in Word: Copy klicken, dann STRG-V in Word. Dort den Tabellenteil ohne Titel anwählen, dann Einfügen/Tabelle/Text in Tabelle umwandeln. Formatvorlagen für Tabelle verwenden. Gute Typographie verwendet wenige vertikale und horizontale Linien, schauen Sie in Büchern oder Publikationen nach, wie eine saubere Tabelle gesetzt wird. </i>"),
        h4("Beispiele für die Formulierung"),
        HTML(
          'Angenommen, in der ersten Zeile steht <code>b-a  2.3 1.0 4.5</code> für Muskelkraftwerte in kg. Dann könnte der Text lauten: "<i>Bei der Gruppe mit Behandlung b ist die Muskelkraft im Mittel um 2.3 kg höher als bei Behandlung a, bei einem 95% Konfidenzintervall KI von 1.0 bis 4.5 kg. Der Unterschied ist signifikant auf dem 5% Niveau.</i>" Warum: weil der Bereich nicht mit 0 überlappt. Beim zweiten Mal können Sie die Kurzform "<i>KI(1.0 bis 4.5) kg</i>" verwenden und das Niveau weglassen;  alternativ die englische Form <it>CI</it>.<br>Steht dort: <code>b-a  0.22 -1.15 1.57</code>, dann schreiben Sie: "<i>Bei der Behandlung (mit) b ist die Muskelkraft im Mittel um 0.22 kg höher als bei Behandlung (mit) a, KI(-1.15 bis 1.57) kg; der Unterschied ist nicht signifikant.</i>" Warum: weil der Bereich mit Null überlappt.'
        ),
        hr(),
        plotOutput("boxplot"),
        hr(),
        DTOutput("box_table"),
        HTML("Median und Quartile, die in den Boxplots dargestellt werden."),
        hr(),
        HTML(
          "<ul><li>Im unten stehende Diagramm ist die vertikale Achse gespreizt. Es kann sein, dass einige Ausreißer deshalb nicht sichtbar sind, aber der zentrale Bereich deutlicher dargestellt wird. Falls Sie diese Darstellung verwenden, bitte fügen Sie in der Bildunterschrift hinzu:'xx Punkte liegen oberhalb des dargestellten Bereichs.'</li></ul>"
        ),
        plotOutput("boxplot1"),
        HTML(
          "<ul><li>Im Box-Whiskers-Plot werden Mediane, Quartile und Ausreißer (outliers) dargestellt. Wenn Sie sehr viele Ausreißer sehen, sollten Sie vielleicht besser nicht den t-Test anwenden; wenn Sie den Datensatz mit dem Beispiel-Button erzeugt haben, bekommen Sie absichtlich viele Ausreißer. Siehe den Artikel in <a href='https://de.wikipedia.org/wiki/Boxplot'>Wikipedia</a>.</li><li>Um die Graphik zu speichern, verwenden Sie im Browser das Menü, das nach Rechtsklick erscheint.</li></ul>"
        )
      ) # wellPanel
    )
  )
))
