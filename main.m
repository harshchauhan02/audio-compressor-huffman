clear all
clc

% Read the input audio file
[audio, fs] = audioread('1.wav');

% Play the original input audio
sound(audio, fs);
pause(length(audio) / fs + 1);  % Pause to ensure the audio finishes playing

%Quantizing the levels of the audio into predefined number of levels
L = 1024;
max_val = max(audio);
min_val = min(audio);
% delta = min_val / ((L - 1) );
delta = (max_val - min_val) / (L - 1);
levels1 = min_val:-delta:0;
level1flp = fliplr(levels1);
%levels = [levels1 -level1flp(2:end)];
levels = min_val:delta:max_val; % Improved levels definition
% Improved levels definition

% diff1 = 0;

diff1 = inf; % Initialize diff1 to a large value

L = 1024;
max_val = max(audio);
min_val = min(audio);




% q is the array containing the values of samples after quantizing

%1
% q = zeros(1, length(audio));
% for i = 1:length(audio)
%     for j = 1:length(levels)
%         diff = abs(audio(i) - levels(j));
%         if diff < diff1
%             q(i) = levels(j);
%         end
%         diff1 = diff;
%     end
%     diff1 = inf; % reset diff1 to a large value
% end
%1

%2
q = zeros(1, length(audio));
for i = 1:length(audio)
    [~, idx] = min(abs(audio(i) - levels)); % Improved quantization method
    q(i) = levels(idx);
end
%2


% 1
% % calculating the probabilities of different symbols or levels
% prob = zeros(1, length(levels));
% for i = 1:length(levels)
%     for j = 1:length(q)
%         if levels(i) == q(j)
%             prob(i) = prob(i) + 1;
%         end
%     end
% end
% prob = prob / length(q);
% 1


%2
% Calculate the probabilities of different levels
prob = zeros(1, length(levels));
for i = 1:length(levels)
    prob(i) = sum(q == levels(i)); % Simplified probability calculation
end
prob = prob / length(q);

% Remove zero probabilities
nonzero_indices = prob > 0; % New: Remove zero probabilities
prob = prob(nonzero_indices);
levels = levels(nonzero_indices);
%2

% Sort probabilities
probval = fliplr(transpose(sortrows(transpose(vertcat(prob, levels)), 1)));
probvalind = [probval; 1:length(levels)];
indexofnzero = find(probvalind(1, :));
probvalindnew = zeros(3, length(indexofnzero)); % Initialize probvalindnew with correct size
for i = 1:3
    probvalindnew(i, 1:length(indexofnzero)) = probvalind(i, 1:length(indexofnzero));
end
prob = probvalindnew(1, :);
[rows, columns] = size(probvalindnew);


% Applying Huffman coding to the probabilities
field1 = 'f';
value1 = {};
s = struct(field1, value1);

field2 = 'c';
value2 = {};
codes = struct(field2, value2);
for i = 1:columns
    codes(i).c = [];
end

for i = 1:columns
    s(1, i).f = probvalindnew(1, i);
    s(2, i).f = probvalindnew(3, i);
end

m = 1;
n = 1;
while s(1, 1).f ~= 1
    rightind = s(2, columns - m + 1).f;
    leftind = s(2, columns - m).f;
    for r = 1:length(rightind)
        e = rightind(r);
        codes(1, e).c = [codes(1, e).c 1];
    end
    for r = 1:length(leftind)
        e = leftind(r);
        codes(1, e).c = [codes(1, e).c 0];
    end
    s(1, columns - m).f = s(1, columns - m).f + s(1, columns - m + 1).f;
    s(2, columns - m).f = [s(2, columns - m).f s(2, columns - m + 1).f];
    n = m;
    if s(1, 1).f ~= 1
        while s(1, columns - n).f > s(1, columns - n - 1).f
            buffer1 = s(1, columns - n).f;
            buffer2 = s(2, columns - n).f;
            s(1, columns - n).f = s(1, columns - n - 1).f;
            s(2, columns - n).f = s(2, columns - n - 1).f;
            s(1, columns - n - 1).f = buffer1;
            s(2, columns - n - 1).f = buffer2;
            n = n + 1;
            if n == columns - 1
                break
            end
        end
    end
    m = m + 1;
end

for i = 1:columns
    codes(i).c = fliplr(codes(i).c);
end


% Calculating entropy
H = 0;
for i = 1:columns
    H = H - prob(i) * log2(prob(i));
end

% Calculating average length after applying Huffman coding
Lav = 0;
for i = 1:columns
    Lav = Lav + prob(i) * length(codes(i).c);
end

% Calculating the efficiency of Huffman code for this speech signal
Efficiency = (H / Lav) * 100;
%disp(['Efficiency of the Huffman code: ', num2str(Efficiency), '%']);


% Encoding the speech signal
field3 = 'e';
value3 = {};
enc = struct(field3, value3);
for i = 1:columns
    rrrr = find(q == probvalindnew(2, i));
    for j = 1:length(rrrr)
        enc(1, rrrr(j)).e = codes(1, i).c;
    end
end
encodedsound = [];

for i = 1:length(q)
    encodedsound = [encodedsound enc(1, i).e];
end

% Debug print: Encoded sound
%------------------------
%disp('Encoded sound:');
%disp(encodedsound);
%-----------------------
% Decoding the speech signal
n = 1;
decodedsoundind = [];
for j = 1:length(q)
    for i = 1:columns
        bool = isequal(codes(1, i).c, encodedsound(n:n + length(codes(1, i).c) - 1));
        if bool == 1
            decodedsoundind(j) = i;
            n = n + length(codes(1, i).c);
            break
        end
    end
end

% Debug print: Decoded sound indices

%disp('Decoded sound indices:');
%disp(decodedsoundind);

% Convert decoded indices back to quantized levels
decodedsound = levels(decodedsoundind);

% %    Debug print: Decoded sound

% disp('Decoded sound:');
% disp(decodedsound);


% Play the decoded output audio
sound(decodedsound, fs);
pause(length(decodedsound) / fs + 1);  % Pause to ensure the audio finishes playing

% Calculate entropy and efficiency
H = -sum(prob .* log2(prob)); % Corrected entropy calculation
Lav = 0;
for i = 1:columns
    Lav = Lav + prob(i) * length(codes(i).c);
end
Efficiency = (H / Lav) * 100; % Corrected efficiency calculation
% Display efficiency
%disp(['Efficiency of the Huffman code: ', num2str(Efficiency), '%']);

% compression ratio calclation
original_size = length(audio) * 16; % Assuming 16 bit PCM audio
encoded_size = length(encodedsound); % lengths in bits
compression_ratio = encoded_size/original_size;
Efficiency = (compression_ratio) * 100;

% display compression ratio
disp(['Compression Ratio: ', num2str(compression_ratio)]);
disp(['Efficiency: ', num2str(Efficiency), '%']);
