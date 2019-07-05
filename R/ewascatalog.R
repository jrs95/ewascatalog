#' ewascatalog
#'
#' ewascatalog queries the EWAS Catalog from R.
#' @param cpgquery a vector of CpG sites.
#' @param regionquery a vector of genomic regions.
#' @param genequery a vector of gene names.
#' @param traitquery a vector of trait names.
#' @return Data frame of EWAS Catalog results.
#' @examples
#' # CpG
#' res <- ewascatalog(cpgquery="cg00029284")
#' 
#' # Region
#' res <- ewascatalog(regionquery="6:15000000-25000000")
#' 
#' # Gene
#' res <- ewascatalog(genequery="FTO")
#' 
#' # Trait
#' res <- ewascatalog(traitquery="body mass index")
#' @author James R Staley <js16174@bristol.ac.uk>
#' @export

ewascatalog <- function(cpgquery=NULL,regionquery=NULL,genequery=NULL,traitquery=NULL){
  if(is.null(cpgquery) & is.null(regionquery) & is.null(genequery) & is.null(traitquery)) stop("no query entered")
  if((length(cpgquery[1])+length(regionquery[1])+length(genequery[1])+length(traitquery[1]))>1) stop("only one query type allowed")
  if(!is.null(regionquery)){
    ub <- as.numeric(sub("*.-", "", sub(".*:", "",regionquery)))
    lb <- as.numeric(sub("-.*", "", sub(".*:", "",regionquery)))
    dist <- ub - lb
    if(any(dist>10000000)) stop("region query can be maximum of 10mb in size")
  }
  if(!is.null(cpgquery)){
    query <- paste0("cpgquery=",cpgquery)
  }
  if(!is.null(regionquery)){
    query <- paste0("regionquery=",regionquery)
  }
  if(!is.null(genequery)){
    query <- paste0("genequery=",genequery)
  }
  if(!is.null(traitquery)){
    query <- paste0("traitquery=",sub(" ", "+", tolower(traitquery)))
  }
  if(length(query)>100) stop("a maximum of 100 queries can be requested at one time")
  results <- data.frame()
  for(i in 1:length(query)){
    json_file <- paste0("http://www.ewascatalog.org/api/?",query[i])
    json_data <- fromJSON(file=json_file)
    if(length(json_data)==0){
      cat("No results for",sub(".*=","",query),"\n")
      next
    }
    fields <- json_data$fields
    tables <- as.data.frame(matrix(unlist(json_data$results), ncol=length(fields), byrow=T))
    names(tables) <- fields
    results <- rbind(results,tables)
  }
  return(results)
}
