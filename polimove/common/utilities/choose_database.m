function [data, selectedName] = choose_database()
    % Specifica la cartella contenente i file
    currentFilePath = mfilename('fullpath');
    functionFolder = fileparts(currentFilePath);
    folderPath = fullfile(functionFolder, '..', '..', 'databases');



    % Verifica che la cartella esista
    if ~isfolder(folderPath)
        error('La cartella "%s" non esiste.', folderPath);
    end

    % Ottieni la lista dei file (escludendo cartelle)
    fileList = dir(folderPath);
    fileNames = {fileList(~[fileList.isdir]).name};

    % Verifica che ci siano file disponibili
    if isempty(fileNames)
        error('Nessun file trovato nella cartella databases.');
    end

    % Mostra la lista dei file e chiedi all'utente di sceglierne uno
    fprintf('Database disponibili:\n');

    % Stampa l'elenco dei file senza l'estensione .mat
    for i = 1:length(fileNames)
        [~, nameWithoutExt, ~] = fileparts(fileNames{i});
        fprintf('%d. %s\n', i, nameWithoutExt);
    end

    % Mostra il messaggio prima della richiesta input
    fprintf('Seleziona un file (1-%d): ', length(fileNames));
    choice = input('');

    % Verifica che la scelta sia valida
    if choice < 1 || choice > length(fileNames) || floor(choice) ~= choice
        error('Scelta non valida.');
    end

    % Carica il file scelto
    selectedFile = fullfile(folderPath, fileNames{choice});
    [~, selectedName, ~] = fileparts(fileNames{choice});

    % Tentativo di caricare il file (assumendo che sia .mat)
    [~, ~, ext] = fileparts(selectedFile);

    switch lower(ext)
        case '.mat'
            fprintf('Hai selezionato: %s\n', selectedName);
            data = selectedFile;
        otherwise
            warning('Estensione "%s" non supportata per il caricamento automatico.', ext);
            data = [];
    end
end
