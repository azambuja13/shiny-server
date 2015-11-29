library(shiny)
library(shinyjs)
library(ggvis)

allgames <- read.csv("data/cfl_games_trim.csv", stringsAsFactors = FALSE) %>%
  arrange(desc(game_date))
  

fluidPage(
  useShinyjs(),
  extendShinyjs("www/shinyjs.js"),
  includeScript("www/main.js"),
  includeCSS("www/style.css"),
  includeCSS("www/tony.css"),
  
  hidden(div(id = "myoverlay")),
  
  div(
    id = "welcome_page",
    div(
      id = "welcome_homevsaway",
      div(id = "welcome_home", "Home"),
      div(id = "welcome_vs", "VS"),
      div(id = "welcome_away", "Away")
    ),
    div(
      id = "welcome_list",
      lapply(
        1:100, function(x) {
          gamedata <- allgames[x, ]
          div(
            class = "welcome_row",
            `data-gameid` = gamedata$sked_id,
            `data-gameinfo` = jsonlite::toJSON(gamedata),
            span(class = "welcome_homename",
                 gamedata$home_team),
            span(class = "welcome_homeimgwrap",
              img(
              class = "welcome_homeimg",
              src = paste0("img/", gamedata$home_team, ".png")
            )),
            span(
              class = "welcome_date",
              format(as.Date(gamedata$game_date), format="%B %d, %Y")
            ),
            span(class = "welcome_awayimgwrap",
              img(
              class = "welcome_awayimg",
              src = paste0("img/", gamedata$away_team, ".png")
            )),
            span(class = "welcome_awayname",
                 gamedata$away_team)          
          )
        }
      )
    )
  ),
  
  hidden(
    div(
      id = "game_page", class = "auto-margin",
      
      # Begin header bar
      div(
        id = "nav-bar", class = "full-width",
        div(id = "back_to_welcome", 
            tags$a(class="btn btn-primary", icon("arrow-left"), "Back")
        ),
        div(
          id = "matchups",
          div(id = "homename", class = "malign", "BC Lions"),
          img(id = "homelogo", class = "team-logo malign", src = "img/BC.png"),
          div(id = "homescore", class = "malign", 20),
          div(id = "game_time", class = "malign",
            textOutput("output_quarter"),
            textOutput("output_time")
          ),
          div(id = "awayscore", class = "malign", 30),
          img(id = "awaylogo", class = "team-logo malign", src = "img/Toronto.png"),
          div(id = "awayname", class = "malign", "Toronto")
        )
      ),    
      div(
        id = "canvas-wrap", class = "auto-margin",
        img(src = "field.png"),
        div(id = "downline",
            img(id = "linehome"),
            img(id = "lineaway")
        ),
        div(id = "downline2"),
        div(id = "deltaline1", class = "deltaline"),
        div(id = "deltaline2", class = "deltaline"),
        div(id = "weather-container",
            div(id = "weathertmp", class = "malign", "BC Lions"),
            img(id = "weathericon", class = "weather-icon")
        )
      ),
      hidden(div(
        id = "youtube_area",
        tags$iframe(id = "youtubeplayer", width="640",height="390",
                    frameborder="0", allowfullscreen="1"),
        img(id = "youtube_close", src = "img/close.png")
      )),
      div(id = "action-bar",
        div(
          id = "time-wrapper", class = "auto-margin",
          h1(id = "action-bar-title", "The Action Bar"),
          img(id = "action-bar-homelogo"),
          img(id = "action-bar-awaylogo"),
          uiOutput("home_events"),
          uiOutput("away_events"),
          sliderInput("time", NULL, 0, MAX_TIME, value = 0, step = 1,
                      ticks = FALSE, width = "800px")
        ),
        
        div(
          id = "buttons_row", class = "auto-margin",
          actionButton("play", "Play", icon = icon("play"),
                       class = "mybtn mybtn-pressed"),
          div(id = "speed-wrap", 
            sliderInput("speed", NULL, min = 1, max = 4, step = 1,
                        value = 1, ticks = TRUE, width = "200px")
          ),
          checkboxGroupInput("eventTypeFilter", NULL,
                             choices = c("Pass", "Rush", "Score"),
                             selected = "Score", inline = TRUE)
        )
      ),
      div(id = "reaction-bar",
          h1(id = "action-bar-title", "The Reaction Bar"),
          ggvisOutput('reactionPlot')
      )      
    )
  )
)