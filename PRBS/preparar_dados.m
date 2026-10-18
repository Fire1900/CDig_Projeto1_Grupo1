% ==============================================================================
% ITEM 1: IMPORTAÇÃO E PRÉ-PROCESSAMENTO DOS DADOS DO PRBS (8 HORAS)
% ==============================================================================
clear; clc; close all;

% 1. Lê o arquivo CSV gravado pelo Python
fprintf('Lendo o arquivo dados_prbs_8h.csv...\n');
dados = readtable('dados_prbs_8h.csv');

% 2. Extrai os vetores de dados (Grandes Sinais)
y_raw  = dados.Temp_Processo;  % Temperatura do processo Y(t) [°C]
u_raw  = dados.PWM;            % Sinal de entrada PWM U(t)
Ta_raw = dados.Temp_Ambiente;  % Temperatura ambiente Ta(t) [°C]

% 3. Converte para Pequenos Sinais (Variáveis de Desvio)
% Passo A: Subtrai a temperatura ambiente do processo (Y - Ta)
y_sub = y_raw - Ta_raw;

% Passo B: Remove a média/offset para operar em torno de zero
y_ident = y_sub - mean(y_sub);
u_ident = u_raw - mean(u_raw);

% 4. Monta a estrutura 'ma' e a variável 'Ta' (padrão Prj1CDig_m.m)
ma.signals(1).values = y_ident;  % Saída em pequenos sinais
ma.signals(2).values = u_ident;  % Entrada em pequenos sinais
Ta = mean(Ta_raw);               % Temperatura ambiente média

% 5. Salva no formato .mat (ex: ma31500.mat)
save('ma31500.mat', 'ma', 'Ta');
fprintf('✅ Arquivo ma31500.mat gerado com sucesso!\n');

% 6. Cria o objeto iddata para o System Identification Toolbox (Ti = 1s)
Ts = 1; % Período de amostragem de 1 segundo
if exist('iddata', 'file') == 2 || exist('iddata', 'builtin') == 5
    dados_id = iddata(y_ident, u_ident, Ts);
    dados_id.InputName  = 'PWM (desvio)';
    dados_id.OutputName = 'Temp Processo (desvio)';
    fprintf('✅ Objeto iddata criado com sucesso!\n');
else
    fprintf('⚠️ Aviso: System Identification Toolbox não detectado nesta instalação. O arquivo ma31500.mat foi gerado normalmente.\n');
end

% 7. Plota os sinais pré-processados para validação visual
figure('Name', 'Pré-processamento PRBS - Pequenos Sinais');
subplot(2,1,1);
plot(u_ident, 'b'); grid on;
title('Sinal de Entrada PRBS - u(t) [Média Zero]');
xlabel('Amostras (s)'); ylabel('PWM (desvio)');

subplot(2,1,2);
plot(y_ident, 'r'); grid on;
title('Resposta do Processo Térmico - y(t) [Y - Ta - Média]');
xlabel('Amostras (s)'); ylabel('Temp (°C desvio)');

saveas(gcf,'DadosBrutos.png')