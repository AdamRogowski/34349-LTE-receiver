clear; close all; clc

fft_size = 64;
N = 8;

% Generate random input bits of size 4*fft_size
input_bits = randi([0 1], 1, 4*fft_size);

% Generate LTE signal samples
LTE_signal = generate_LTE_signal(input_bits, fft_size);

% Receive LTE signal samples
LTE_subcarriers = receive_LTE_signal(LTE_signal, fft_size);

output_bits = demodulate_LTE_signal(LTE_subcarriers);

function LTE_signal = generate_LTE_signal(bits, fft_size)
    % Modulation scheme (16-QAM)
    modulation_order = 16; % 16-QAM
    k = log2(modulation_order); % Number of bits per symbol

    % Convert bits to decimal
    symbols = bi2de(reshape(bits, k, [])', 'left-msb');

    % Perform modulation
    modulated_symbols = qammod(symbols, modulation_order, 'UnitAveragePower', true);

    % Reshape the symbols into a matrix for IFFT
    symbols_matrix = reshape(modulated_symbols, [], fft_size);

    % Perform IFFT
    time_domain_signal = ifft(symbols_matrix);

    % Output vector of LTE signal samples
    LTE_signal = time_domain_signal(:).';
end

function LTE_subcarriers = receive_LTE_signal(LTE_signal, fft_size)
    % Reshape the LTE signal into a matrix for FFT
    signal_matrix = reshape(LTE_signal, fft_size, []);

    % Perform FFT
    frequency_domain_signal = fft(signal_matrix);

    LTE_subcarriers = frequency_domain_signal(:);
end

function output_bits = demodulate_LTE_signal(subcarriers)
    % Demodulation scheme (16-QAM)
    modulation_order = 16; % 16-QAM
    k = log2(modulation_order); % Number of bits per symbol

    % Perform demodulation
    demodulated_symbols = qamdemod(subcarriers, modulation_order);

    % Convert symbols to bits
    output_bits = de2bi(demodulated_symbols', k, 'left-msb');
    output_bits = output_bits(:).';
end