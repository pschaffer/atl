if(!require(shiny)){
  stop("Please run install.packages('shiny')!")
}

library(R.utils) #for gzip

ui <- fluidPage(
   fileInput(inputId = "fileToLoad", label = "Upload file!"),
   textOutput("out.string")
  )

#vector of column names for dataframe
header.lst <- c('customer.id', 'first.name', 'last.name','address','state','zip',
            'purchase.status', 'product.id', 'product.name','purchase.amount',
            'datetime')

run.page <- function(input,output){
  req(input$fileToLoad)
  inFile <- input$fileToLoad
  df.in <- read.csv(inFile$datapath, sep = '\t',header = FALSE, col.names = header.lst, stringsAsFactors = FALSE)
  
  #create purchase id variable by concatenating customer and product ids, separated by a space
  df.in$purchase.id <- paste(df.in$customer.id, df.in$product.id)
  
  #check for zips with more than or fewer than 5 chars
  zip.fail <- sum(nchar(df.in$zip) != 5) > 0
  
  #check for canceled purchases that were never new
  canceled.ids <- (df.in$purchase.id[df.in$purchase.status == 'canceled'])
  new.ids <- (df.in$purchase.id[df.in$purchase.status == 'new'])
  cancel.fail <- sum(!(canceled.ids %in% new.ids))
  
  success <- FALSE
  out.str <- ''
  
  if(zip.fail) {out.str <- 'Invalid zips! At least one is not 5 characters, please fix and reupload.\n'}
  if(cancel.fail) {
    out.str <- paste(out.str, 
                        'At least one canceled purchase was never a new purchase, please fix and reupload.\n',
                        sep = '')              
    }
  if(out.str == '') {
    out.str <- 'File has no errors!'
    success <- TRUE
    }
  
  if(success){
    #gzip file for upload speed
    gzip(inFile$datapath, 'loadme.txt.gz',remove = FALSE,overwrite = TRUE)
    #ship to db
    source(send_to_db.R)
    }
  
  #send success or failure message to UI
  out.str
  }

server <- function(input,output) {
  output$out.string <- renderText( run.page(input,output) )
  }

shinyApp(ui = ui, server = server)