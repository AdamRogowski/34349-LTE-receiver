clear; close all; clc

import comm.QPSKModulator;
import comm.QPSKDemodulator;

fft_size = 8;

% Generate random input bits of size 2*fft_size
input_bits = randi([0 1], 1, 2*fft_size);

% Generate LTE signal samples
LTE_signal = generate_LTE_signal(input_bits, fft_size);

% Convert LTE signal to fixed-point
fixed_point_signal = convert_to_fixed_point(LTE_signal);

% Receive LTE signal samples
output_bits = receive_LTE_signal(LTE_signal, fft_size);

function LTE_signal = generate_LTE_signal(bits, fft_size)
    % Modulation scheme (QPSK)
    modulation_order = 4; % QPSK
    modulator = comm.QPSKModulator('BitInput', true, 'PhaseOffset', pi/4, 'SymbolMapping', 'Gray');
    symbols = step(modulator, bits.');

    % Reshape the symbols into a matrix for IFFT
    symbols_matrix = reshape(symbols, [], fft_size);

    % Perform IFFT
    time_domain_signal = ifft(symbols_matrix);

    % Output vector of LTE signal samples
    LTE_signal = time_domain_signal(:).';

    % Display symbols
    %disp('Generated symbols:');
    %disp(symbols);

    % Display the generated LTE signal samples
    disp('Generated LTE signal samples:');
    disp(LTE_signal);
end

function output_bits = receive_LTE_signal(LTE_signal, fft_size)
    % Reshape the LTE signal into a matrix for FFT
    signal_matrix = reshape(LTE_signal, fft_size, []);

    % Perform FFT
    frequency_domain_signal = fft(signal_matrix);

    % Display the frequency samples
    disp('Frequency samples:');
    disp(frequency_domain_signal(:).');

    % Demodulation scheme (QPSK)
    demodulator = comm.QPSKDemodulator('BitOutput', true, 'PhaseOffset', pi/4, 'SymbolMapping', 'Gray');
    demodulated_symbols = step(demodulator, frequency_domain_signal(:));

    % Display the output bits
    disp('Output bits:');
    disp(demodulated_symbols.');

    output_bits = demodulated_symbols.';
end

function fixed_point_signal = convert_to_fixed_point(LTE_signal)
    % Create a fixed-point data type with 1 sign bit, 9 integer bits, and 6 fractional bits
    T = numerictype('WordLength', 16, 'FractionLength', 6, 'Signed', true);

    % Convert the LTE signal to fixed-point
    fixed_point_signal = fi(LTE_signal, T);

    % Display the fixed-point signal with 6 decimal places
    disp('Fixed-point signal:');
    for i = 1:length(fixed_point_signal)
        fprintf('%.6f + %.6fi\n', real(fixed_point_signal(i)), imag(fixed_point_signal(i)));
    end
end

