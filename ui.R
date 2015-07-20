library(shinyAce)

shinyUI(fluidPage(
  titlePanel("Ungepaarter Wilcoxon-Test (Mann-Whitney U-Test) nach Gruppen"),

  sidebarLayout(
    sidebarPanel( "",
      actionButton("computeButton","Berechnen"),
      actionButton("clearButton","Löschen"),
      textOutput("results"),
      imageOutput("helpImage")
    ),
    mainPanel("Daten: Zweispaltige Excel-Daten aus der Zwischenablage mit STRG-V hier eingeben",
      aceEditor("data", "", mode = "r"),
      plotOutput("diffplot"),
      DT::dataTableOutput('table')
    )
  )
))

