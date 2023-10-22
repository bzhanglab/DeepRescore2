read.mgf = function(file) {
  lines = readLines(con = file)
  
  begin.indexs = grep(pattern = 'BEGIN IONS', x = lines)
  end.indexs = grep(pattern = 'END IONS', x = lines)
  
  lapply(1:length(begin.indexs), function(i) {
    internal.lines = lines[begin.indexs[i]:end.indexs[i]]
    
    fields.indexs = grep(pattern = '=', internal.lines)
    fields = strsplit(internal.lines[fields.indexs], '=')
    fields.name = sapply(fields, function(s) s[1])
    fields = substring(internal.lines[fields.indexs], nchar(fields.name) + 2)
    names(fields) = fields.name
    
    title = fields['TITLE']
    charge = fields['CHARGE']
    pepMass = as.double(strsplit(fields['PEPMASS'], ' ')[[1]])
    rtInSeconds = as.double(strsplit(fields['RTINSECONDS'], ' ')[[1]])
    
    ion.indexs = -c(1, length(internal.lines), grep(pattern = '=', internal.lines))
    records = strsplit(internal.lines[ion.indexs], split = ' |\t')
    if(length(records) > 0)
      ions = do.call(rbind, lapply(records, function(record) {
        as.numeric(record[1:2])
      }))
    else
      ions = matrix(ncol = 2, nrow = 0)
    colnames(ions) = c('mz', 'intensity')
    
    list(ions = ions, title = title, charge = charge, pepMass = pepMass, rtInSeconds = rtInSeconds, fields = fields)
  })
}

#install.packages('XML')
library(XML)
library(readr)

args <- commandArgs(T)
psmPaths <- args[1]
mgfPaths <- args[2]
pathouts <- args[3]
Mods <- args[4]

#psmPaths = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/UCEC/PhosphoRS_maxquant/TXT'
#mgfPaths = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/tmp/InputData_UCEC/MGF'
#pathouts = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/UCEC/PhosphoRS_maxquant/xml'
#Mods = '1,Oxidation,M,15.994919,1;2,Phospho,S,79.966331,2;3,Phospho,T,79.966331,2;4,Phospho,Y,79.966331,2;6,TMT6plex,K,229.162932,4;5,Carbamidomethyl,C,57.021464,3;7,TMT6plex,AnyN-term,229.162932,5'

Mods2 = unlist(strsplit(Mods,';',fixed = TRUE))
startNumber = '0.'
number = c()
for (i in 1:length(Mods2)){
  tmp = Mods2[i]
  tmp2 = unlist(strsplit(tmp,',',fixed = TRUE))
  if (tmp2[3] != 'AnyN-term'){
    number = c(number,tmp2[5])
  }
  if (tmp2[3] == 'AnyN-term'){
    startNumber = paste0(tmp2[5],'.')
  }
}
number2 = unique(number)
number2 = number2[order(number2,decreasing = FALSE)]
ModNum = ''
for (i in 1:length(number2)){
  ModNum <- paste0(ModNum,number2[i])
}


FileNames = list.files(psmPaths)

activationTypes = 'HCD'
massTolerance = 0.02
scoreNeutralLoss = FALSE

spectra.file = ''
spectra = NULL
spectrumTitle = NULL

for (count in 1:length(FileNames)){

FileName = FileNames[count]

FileName2 = gsub(".txt", "", FileName)

psm = read.csv(paste0(psmPaths,'/',FileName),sep = '\t')
mgfPath = paste0(mgfPaths,'/',FileName2,'.mgf')
pathout = paste0(pathouts,'/',FileName2,'.xml')

spectraNode = newXMLNode('Spectra', lapply(1:nrow(psm), function(i) {
  file = mgfPath
  if (file != spectra.file || is.null(spectra)) {
    spectra.file <<- file
    message(paste0(Sys.time(), ': loading ', spectra.file))
    spectra <<- read.mgf(spectra.file)
    message(paste0(Sys.time(), ': ', spectra.file, ' loaded'))
    spectrumTitle <<- sapply(spectra, function(x) sub('^(.*\\.[0-9]+\\.[0-9]+)\\.[0-9]* .*', '\\1', x$title))
  }
  
  queryTitle = sprintf('%s.%d.%d.%d', psm$file[i], psm$scan[i], psm$scan[i], psm$charge[i])
  spectrumIndex = match(queryTitle, spectrumTitle)
  if (is.na(spectrumIndex)) {
    message(paste0(Sys.time(), ': ', queryTitle, ' spectrum not found '))
    return(NULL)
  }
  
  name = as.character(spectra[[spectrumIndex]]$title)
  charge = as.integer(psm$charge[i])
  #sequence = gsub('[12]', '', psm$peptide[i])
  sequence = gsub(paste0('[',ModNum,']'), '', psm$peptide[i])
  modification = paste0(startNumber, gsub('[A-Z]', '0', gsub(paste0('[A-Z]([',ModNum,'])'), '\\1', psm$peptide[i])), '.0')
  
  peaks = paste0(sapply(1:nrow(spectra[[spectrumIndex]]$ions), function(i) {
    paste0(spectra[[spectrumIndex]]$ions[i, 1:2], collapse = ':')
  }), collapse = ',')
  
  newXMLNode(
    'Spectrum', attrs = list(ID = i, Name = name, PrecursorCharge = charge, ActivationTypes = activationTypes),
    newXMLNode('Peaks', newXMLTextNode(peaks)),
    newXMLNode('IdentifiedPhosphorPeptides', newXMLNode(
      'Peptide', attrs = list(ID = i, Sequence = sequence, ModificationInfo = modification)
    ))
  )
}))

phosphoRSInput = newXMLNode(
  'phosphoRSInput',
  newXMLNode('MassTolerance', attrs = list(Value = massTolerance)),
  newXMLNode('Phosphorylation', attrs = list(Symbol = '2')),
  newXMLNode('ScoreNeutralLoss', attrs = list(Value = tolower(as.character(scoreNeutralLoss)))),
  spectraNode,
  newXMLNode(
    'ModificationInfos', 
    newXMLNode('ModificationInfo', attrs = list(
      Symbol = '2', 
      Value = '2:Phospho:Phospho:79.966331:PhosphoLoss:97.976896:STY'
    )),
    newXMLNode('ModificationInfo', attrs = list(
      Symbol = '1', 
      Value = '1:Oxidation:Oxidation:15.994919:null:0:M'
    )),
    newXMLNode('ModificationInfo', attrs = list(
      Symbol = '3', 
      Value = '3:Carbamidomethyl:Carbamidomethyl:57.021464:null:0:C'
    )),
    newXMLNode('ModificationInfo', attrs = list(
      Symbol = '4',
      Value = '4:TMT:TMT:229.162932:null:0:K'
    )),
    newXMLNode('ModificationInfo', attrs = list(
      Symbol = '5',
      Value = '5:TMT:TMT:229.162932:null:0:N-term'
    ))
  )
)

saveXML(phosphoRSInput, file = pathout)

}

  
  

