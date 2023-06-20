function Ex5()
    % Step 1: Data Preparation
    participant = '02';
    digits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]; % List of digits in your dataset
    recordingsPerDigit = 50;
    resolution = 100; % Lower resolution for less smooth lines
    
    spectra = cell(1, numel(digits)); % Cell array to store the amplitude spectra for each digit
    first_quartile = cell(1, numel(digits)); % Cell array to store the first quartile for each digit
    third_quartile = cell(1, numel(digits)); % Cell array to store the third quartile for each digit
    
    for digitIndex = 1:numel(digits)
        digit = digits(digitIndex);
        signals = cell(1, recordingsPerDigit); % Cell array to store signals for the current digit
        
        % Load the signals for the current digit
        for recording = 1:recordingsPerDigit-1
            [soundData, sampleRate] = loadRec(digit, participant, recording);            
            soundData = zeroPadding(soundData, max(sampleRate));
            signals{recording} = soundData;
        end
        
        % Calculate the amplitude spectra for each signal
        amplitude_spectra = zeros(recordingsPerDigit, resolution/2+1);
        for i = 1:recordingsPerDigit-1
            signal = signals{i};
            N = numel(signal);
            spectrum = abs(fft(signal, resolution)); % Compute the Fourier spectrum with lower resolution
            amplitude_spectrum = spectrum(1:resolution/2+1); % Keep only frequencies up to the Nyquist frequency
            amplitude_spectra(i, :) = amplitude_spectrum;
        end
        
        % Calculate the median and quartiles for the amplitude spectra
        median_spectrum = median(amplitude_spectra, 1);
        first_quartile_spectrum = quantile(amplitude_spectra, 0.25);
        third_quartile_spectrum = quantile(amplitude_spectra, 0.75);
        
        % Normalize the spectra by the number of samples
        median_spectrum = median_spectrum / N;
        first_quartile_spectrum = first_quartile_spectrum / N;
        third_quartile_spectrum = third_quartile_spectrum / N;
        
        % Store the spectra and quartiles for the current digit
        spectra{digitIndex} = median_spectrum;
        first_quartile{digitIndex} = first_quartile_spectrum;
        third_quartile{digitIndex} = third_quartile_spectrum;
    end
    
    % Plotting the results
    frequencies = linspace(0, sampleRate/2, resolution/2+1);
    
    figure;
    colors = lines(numel(digits)); % Generate a color map for the lines
    
    for i = 1:numel(digits)
        subplot(2, 5, i);
        hold on;
        plot(frequencies, 20*log10(spectra{i}), 'b', 'LineWidth', 1);
        plot(frequencies, 20*log10(first_quartile{i}), '--r', 'LineWidth', 1);
        plot(frequencies, 20*log10(third_quartile{i}), '--k', 'LineWidth', 1);
        xlabel('Frequency (Hz)');
        ylabel('Amplitude (dB)');
        title(['Digit ', num2str(digits(i))]);
        legend('Median', 'First Quartile', 'Third Quartile');
    end
end
