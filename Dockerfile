FROM mykter/afl-training 

#ENV test test

RUN apt update
RUN apt upgrade -y
RUN apt install -y bash-completion build-essential git screen tmate thefuck sudo nano net-tools iproute2 netcat

USER fuzzer
RUN echo 'alias modificaprofilo="nano ~/.bashrc" \nalias ricaricaprofilo="source ~/.bashrc" \nalias ..="cd .." \nalias ...="cd ../.." ' >> /home/fuzzer/.bashrc

# seguo istruzioni nel readme
# contiene la cartella git
WORKDIR /home/fuzzer/workshop/challenges/libxml2/
RUN git submodule init
RUN git submodule update

# compilo libreria libxml2
WORKDIR /home/fuzzer/workshop/challenges/libxml2/libxml2
RUN ls -la
RUN CC=afl-clang-fast ./autogen.sh
RUN AFL_USE_ASAN=1 make
# valutare -j 4

# compilo esempio harness
WORKDIR /home/fuzzer/workshop/challenges/libxml2/
COPY harness_xml.c .
RUN AFL_USE_ASAN=1 afl-clang-fast ./harness_xml.c -I libxml2/include libxml2/.libs/libxml2.a -lz -lm -o harness_xml 

# scarico libreria test
RUN git clone https://github.com/dvyukov/go-fuzz-corpus.git /home/fuzzer/go-fuzz-corpus

# libreria openssl
WORKDIR /home/fuzzer/workshop/challenges/heartbleed/openssl/
RUN CC=afl-clang-fast CXX=afl-clang-fast++ ./config -d
RUN AFL_USE_ASAN=1 make

# build handshake.cc
WORKDIR /home/fuzzer/workshop/challenges/heartbleed/
COPY handshake-soluzione-github.cc handshake.cc
RUN AFL_USE_ASAN=1 afl-clang-fast++ -g handshake.cc openssl/libssl.a openssl/libcrypto.a -o handshake -I openssl/include -ldl



# fine
WORKDIR /home/fuzzer/workshop/challenges/
# compilo libreria
#WORKDIR workshop/challenges/libxml2/libxml2
#RUN git clone https://gitlab.gnome.org/GNOME/libxml2.git .
#RUN CC=afl-clang-fast ./autogen.sh
#RUN CC=afl-clang-fast ./configure --with-python=no --disable-shared
#RUN AFL_USE_ASAN=1 make -j 6

# codice test
#COPY harness.c harness.c
#RUN afl-clang-fast -fsanitize=address harness.c .libs/libxml2.a -Iinclude -lz -o harness

#RUN git clone https://github.com/dvyukov/go-fuzz-corpus.git /home/fuzzer/go-fuzz-corpus
#RUN afl-fuzz -i /home/fuzzer/go-fuzz-corpus/xml/corpus/ -o afl_libxml2 -m 1000 -- ./harness @@

#EXPOSE 22
#ENTRYPOINT ["./entrypoint.sh"]
CMD ["bash"]

# originali slide prof:
#CC=afl-clang-fast CFLAGS="-m32" ./autogen.sh
#CC=afl-clang-fast CFLAGS="-m32" ./configure --with-python=no --disable-shared
#AFL_USE_ASAN=1 make -j 2
#afl-clang-fast -m32 -fsanitize=address harness.c .libs/libxml2.a -Iinclude –lz -o harness
#afl-clang-fast -fsanitize=address main.c libxml2/libxml2.la -Iinclude -lz -o harness
#afl-fuzz -i go-fuzz-corpus/xml/corpus/ -o afl_libxml2 -m 1000 -- ./harness @@

# extra
#sudo /home/corso/SoftwareSecurity/afl/AFL/experimental/asan_cgroups/limit_memory.sh -u corso
# DEVE ESSERE ESEGUITO CON PRIVILEGED
# sudo /home/fuzzer/afl-2.52b/experimental/asan_cgroups/limit_memory.sh -u root -m 8000 afl-fuzz -i ~/go-fuzz-corpus/xml/corpus/ -o afl_libxml2 -m 1000 -- ./harness @@

# note:
# per libxml2: questo funziona alla prima botta:
# afl-fuzz -m none -i ~/go-fuzz-corpus/xml/corpus/ -o out_risultati -x ~/afl-2.52b/dictionaries/xml.dict ./harness_xml @@
# quello della lezione deve essere adattate
# 
