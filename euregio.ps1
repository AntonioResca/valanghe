# Definisci l'URL del bollettino
$url = "https://static.avalanche.report/bulletins/latest/EUREGIO_it_CAAMLv6.json"
#$url = "https://static.avalanche.report/bulletins/2025-02-09/2025-02-09_EUREGIO_it_CAAMLv6.json"

# Definisci il nome del file di output JSON
$fileOutput = "euregio.json"

# Lista delle regioni da filtrare
$regioniTarget = @("Brenta settentrionale - Peller", "Brenta meridionale", "Latemar")

# di quale avalanche problem dobbiamo tracciare il limite bosco 
# $avalancheProblemTarget = "persistent_weak_layers"
# DA CHIARIRE: prendo il primo

try {
    # Scarica il contenuto JSON dall'URL
    $jsonContent = Invoke-RestMethod -Uri $url -UseBasicParsing

    # Inizializza un array per memorizzare i risultati
    $risultati = @()

    # Itera sui bollettini
    foreach ($bollettino in $jsonContent.bulletins) {
        # Controlla se il bollettino contiene almeno una regione target
        if ($null -ne $bollettino.regions) {
            foreach ($regione in $bollettino.regions) {
                # Filtra solo le regioni desiderate
                if ($regione.name -in $regioniTarget) {
                    # Trova i dangerRatings associati alla regione
                    $sopraBosco = $bollettino.dangerRatings[0]
                    $sottoBosco = $bollettino.dangerRatings[1]

                    # Estrai il limite del bosco dagli avalancheProblems
                    $limiteBosco = ""
                    if ($null -ne $bollettino.avalancheProblems) {
                        $limiteBosco = $bollettino.avalancheProblems[0].elevation.lowerBound
                        # foreach ($problem in $bollettino.avalancheProblems) {
                        #     if ($problem.problemType -eq $avalancheProblemTarget) {
                        #         $limiteBosco = $problem.elevation.lowerBound
                        #     }
                        # }
                    }
                    # Crea un oggetto con i campi richiesti
                    $riga = [PSCustomObject]@{
                        "ZONA"                = $regione.name
                        "VALANGHE SOTTOBOSCO" = $sottoBosco.mainValue
                        "VALANGHE SOPRABOSCO" = $sopraBosco.mainValue
                        "LIMITE BOSCO"        = $limiteBosco
                    }

                    # Aggiungi la riga ai risultati
                    $risultati += $riga
                }
            }
        }
    }

    # Esporta i risultati in un file JSON
    if ($risultati.Count -gt 0) {
        $risultati | ConvertTo-Json -Depth 10 | Set-Content -Path $fileOutput -Encoding UTF8
        Write-Output "File JSON generato correttamente: $fileOutput"
    }
    else {
        Write-Output "Nessuna regione corrispondente trovata nei dati."
    }
}
catch {
    Write-Output "Errore durante il recupero o l'elaborazione dei dati: $($Error[0].Message)"
}