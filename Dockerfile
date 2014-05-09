# Solazyme Bioinformatics Container
#
# A portable analysis environment capable of running on any system or virtual machine
# with linux and Docker installed
# version 0.1

FROM phusion/baseimage

MAINTAINER Timothy Laurent

#install required libs
RUN apt-get update && apt-get install -y -q git build-essential autotools-dev automake pkg-config curl wget;\
    mkdir /install && cd install ;\
    apt-get install python-setuptools python-dev -y -q \;
    cd /install ;\
    git clone https://github.com/timothyjlaurent/cloudbiolinux.git ;\
    cd cloudbiolinux ;\
    git checkout 1a1fc199f8a3729e0231dd8413e33bbea1a0f1b9
    ls ;\
    pwd;\
    python setup.py build ;\
    sudo python setup.py install;\
    cd cloudbiolinux;\
    fab -f fabfile.py -H localhost -c config/fabricrc.txt install_biolinux:packages; \
    fab -f fabfile.py -H localhost install_biolinux:libraries && apt-get clean ;\
	fab -f fabfile.py -H localhost -c install_biolinux:cleanup ;\
	rm -rf /var/lib/apt/lists/* /var/tmp/* /var/tmp/*



RUN    mkdir /software && cd software ;\
# install bowtie 2
    wget http://downloads.sourceforge.net/project/bowtie-bio/bowtie2/2.2.2/bowtie2-2.2.2-linux-x86_64.zip ;\
    unzip bowtie2-2.2.2-linux-x86_64.zip && rm -rf bowtie2-2.2.2-linux-x86_64.zip ;\
    ln -s `pwd`/bowtie*/bowtie* /usr/local/bin;\
# install rsem
    wget http://deweylab.biostat.wisc.edu/rsem/src/rsem-1.2.12.tar.gz && tar -xaf rsem-1.2.12.tar.gz && rm rsem-1.2.12.tar.gz ;\
    cd rsem-1.2.12 ;\
    make && make ebseq && ln -s `pwd`/* /usr/local/bin;\
## install Anaconda
    cd /software && wget http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.9.2-Linux-x86_64.sh && bash Anaconda-1.9.2-Linux-x86_64.sh -b && rm -rf Anaconda-1.9.2-Linux-x86_64.sh ;\
    mv /root/anaconda/lib/python2.7/platform.py /root/anaconda/lib/python2.7/platform.pybak && cp /usr/lib/python2.7/platform.py /root/anaconda/lib/python2.7/platform.py;\
#RUN ln -s /root/anaconda/bin/* /usr/local/bin/
## This is done to fix a bug with the anaconda platform.py



ENV PATH $PATH:/root/anaconda/bin/


# install blast
RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.29/ncbi-blast-2.2.29+-x64-linux.tar.gz && tar -xaf ncbi-blast-2.2.29+-x64-linux.tar.gz && rm -rf rm ncbi-blast-2.2.29+-x64-linux.tar.gz ;\
    ln -s `pwd`/ncbi-blast-2.2.29+/bin/* /usr/local/bin/
#ENV PATH /software/ncbi-blast-2.2.29+/bin/:$PATH

# install quast
# RUN apt-get install csh python-matplotlib -y -q
RUN wget http://downloads.sourceforge.net/project/quast/quast-2.3.tar.gz && tar -xaf quast-2.3.tar.gz && rm -rf quast-2.3.tar.gz && ln -s `pwd`/quast*/* /usr/local/bin/
#ENV PATH /software/quast-2.3/:$PATH


# install tophat2
RUN wget http://tophat.cbcb.umd.edu/downloads/tophat-2.0.11.Linux_x86_64.tar.gz && tar -xaf tophat-2.0.11.Linux_x86_64.tar.gz && rm -rf tophat-2.0.11.Linux_x86_64.tar.gz && ln -s `pwd`/tophat*/tophat2 /usr/local/bin/

# install cufflinks
RUN wget http://cufflinks.cbcb.umd.edu/downloads/cufflinks-2.2.0.Linux_x86_64.tar.gz && tar -xaf cufflinks-2.2.0.Linux_x86_64.tar.gz && rm -rf cufflinks-2.2.0.Linux_x86_64.tar.gz && ln -s `pwd`/cuff*/cuff* /usr/local/bin/

# install Augustus 3
RUN apt-get install libboost-iostreams-dev libboost-system-dev libboost-filesystem-dev -y -q && apt-get clean ;\
    wget http://szyme-backup.dyndns.org:42080/\~admin/augustus-3.0.2.tar.gz && tar -xaf augustus-3.0.2.tar.gz && rm augustus*tar.gz ;\
    cd augustus-3.0.2/src && make && cd ..;\
    ln -f -s `pwd`/bin/* /usr/local/bin && ln -f -s `pwd`/scripts/* /usr/local/bin

# install picard
# this also sets the jars as 'executable' and puts them in the path so they can be found wiht the 'which ' command
RUN wget http://downloads.sourceforge.net/project/picard/picard-tools/1.111/picard-tools-1.111.zip && unzip picard-tools-1.111.zip && rm -rf picard-tools-1.111.zip && chmod +x picard*/*.jar && ln -s `pwd`/picard*/*.jar /usr/local/bin/

#install samtools
RUN wget http://downloads.sourceforge.net/project/samtools/samtools/0.1.19/samtools-0.1.19.tar.bz2 && tar -xaf samtools-0.1.19.tar.bz2 && rm -rf samtools-0.1.19.tar.bz2 ;\
    cd samtools-0.1.19;\
    make && make razip && ln -f -s `pwd`/* /usr/local/bin


#install velvet
RUN wget https://www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.10.tgz && tar -xaf velvet_1.2.10.tgz && rm velvet_1.2.10.tgz ;\
    cd velvet_1.2.10 ;\
    make 'OPENMP=1' 'BIGASSEMBLY=1' 'MAXKMERLENGTH=99'  && ln -f -s `pwd`/* /usr/local/bin/


#install trinity
RUN wget http://downloads.sourceforge.net/project/trinityrnaseq/trinityrnaseq_r20140413.tar.gz && tar -xaf trinityrnaseq_r20140413.tar.gz && rm trinityrnaseq_r20140413.tar.gz ;\
    cd trinityrnaseq_r20140413 ;\
    make && ln -f -s `pwd`/* /usr/local/bin/


#install fastqc
RUN wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.10.1.zip && unzip fastqc_v0.10.1.zip && rm fastqc_v0.10.1.zip && chmod +x FastQC/fastqc && ln -f -s `pwd`/FastQC/* /usr/local/bin/


# some tools taken from https://github.com/thierrymarianne/zen-cmd/blob/master/Dockerfile
RUN apt-get install -y -q vim htop locate && git clone git://git.code.sf.net/p/tmux/tmux-code /opt/src/tmux-code && apt-get clean ;\
    cd /opt/src/tmux-code ;\
    git fetch --all && git checkout tags/1.9 && apt-get install -y -q libncurses5-dev libevent-dev && apt-get install -y -q  && sh autogen.sh && ./configure --prefix=/opt/local/tmux && make && make install && ln -s /opt/local/tmux/bin/tmux /usr/bin ;\
    apt-get clean

# repos for python 3.3
RUN apt-get install python-software-properties -y -q && add-apt-repository ppa:fkrull/deadsnakes -y && apt-get update && apt-get install python3.3 zip python-pip -y -q && apt-get clean

	fab -f fabfile.py -H localhost -c install_biolinux:cleanup ;\
	rm -rf /var/lib/apt/lists/* /var/tmp/* && \
	rm -rf /.cpanm 


RUN mkdir /software 

WORKDIR /software

# install bowtie 2
RUN wget http://downloads.sourceforge.net/project/bowtie-bio/bowtie2/2.2.2/bowtie2-2.2.2-linux-x86_64.zip ;\
    unzip bowtie2-2.2.2-linux-x86_64.zip && rm -rf bowtie2-2.2.2-linux-x86_64.zip ;\
    ln -s `pwd`/bowtie*/bowtie* /usr/local/bin

# install rsem
RUN wget http://deweylab.biostat.wisc.edu/rsem/src/rsem-1.2.12.tar.gz && tar -xaf rsem-1.2.12.tar.gz && rm rsem-1.2.12.tar.gz ;\
    cd rsem-1.2.12 ;\
    make && make ebseq && ln -s `pwd`/* /usr/local/bin


# install open jdk-6
RUN apt-get install default-jdk -y -q && apt-get clean

## install Anaconda
RUN  wget http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.9.2-Linux-x86_64.sh && bash Anaconda-1.9.2-Linux-x86_64.sh -b && rm -rf Anaconda-1.9.2-Linux-x86_64.sh ;\
    mv /root/anaconda/lib/python2.7/platform.py /root/anaconda/lib/python2.7/platform.pybak && cp /usr/lib/python2.7/platform.py /root/anaconda/lib/python2.7/platform.py
#RUN ln -s /root/anaconda/bin/* /usr/local/bin/
## This is done to fix a bug with the anaconda platform.py
ENV PATH $PATH:/root/anaconda/bin/


# install blast
RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.29/ncbi-blast-2.2.29+-x64-linux.tar.gz && tar -xaf ncbi-blast-2.2.29+-x64-linux.tar.gz && rm -rf rm ncbi-blast-2.2.29+-x64-linux.tar.gz ;\
    ln -s `pwd`/ncbi-blast-2.2.29+/bin/* /usr/local/bin/
#ENV PATH /software/ncbi-blast-2.2.29+/bin/:$PATH

# install quast
# RUN apt-get install csh python-matplotlib -y -q
RUN wget http://downloads.sourceforge.net/project/quast/quast-2.3.tar.gz && tar -xaf quast-2.3.tar.gz && rm -rf quast-2.3.tar.gz && ln -s `pwd`/quast*/* /usr/local/bin/
#ENV PATH /software/quast-2.3/:$PATH


# install tophat2
RUN wget http://tophat.cbcb.umd.edu/downloads/tophat-2.0.11.Linux_x86_64.tar.gz && tar -xaf tophat-2.0.11.Linux_x86_64.tar.gz && rm -rf tophat-2.0.11.Linux_x86_64.tar.gz && ln -s `pwd`/tophat*/tophat2 /usr/local/bin/

# install cufflinks
RUN wget http://cufflinks.cbcb.umd.edu/downloads/cufflinks-2.2.0.Linux_x86_64.tar.gz && tar -xaf cufflinks-2.2.0.Linux_x86_64.tar.gz && rm -rf cufflinks-2.2.0.Linux_x86_64.tar.gz && ln -s `pwd`/cuff*/cuff* /usr/local/bin/

# install Augustus 3
RUN apt-get install libboost-iostreams-dev libboost-system-dev libboost-filesystem-dev -y -q && apt-get clean ;\
    wget http://szyme-backup.dyndns.org:42080/\~admin/augustus-3.0.2.tar.gz && tar -xaf augustus-3.0.2.tar.gz && rm augustus*tar.gz ;\
    cd augustus-3.0.2/src && make && cd ..;\
    ln -f -s `pwd`/bin/* /usr/local/bin && ln -f -s `pwd`/scripts/* /usr/local/bin

# install picard
# this also sets the jars as 'executable' and puts them in the path so they can be found wiht the 'which ' command
RUN wget http://downloads.sourceforge.net/project/picard/picard-tools/1.111/picard-tools-1.111.zip && unzip picard-tools-1.111.zip && rm -rf picard-tools-1.111.zip && chmod +x picard*/*.jar && ln -s `pwd`/picard*/*.jar /usr/local/bin/

#install samtools
RUN wget http://downloads.sourceforge.net/project/samtools/samtools/0.1.19/samtools-0.1.19.tar.bz2 && tar -xaf samtools-0.1.19.tar.bz2 && rm -rf samtools-0.1.19.tar.bz2 ;\
    cd samtools-0.1.19;\
    make && make razip && ln -f -s `pwd`/* /usr/local/bin


#install velvet
RUN wget https://www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.10.tgz && tar -xaf velvet_1.2.10.tgz && rm velvet_1.2.10.tgz ;\
    cd velvet_1.2.10 ;\
    make 'OPENMP=1' 'BIGASSEMBLY=1' 'MAXKMERLENGTH=99'  && ln -f -s `pwd`/* /usr/local/bin/


#install trinity
RUN wget http://downloads.sourceforge.net/project/trinityrnaseq/trinityrnaseq_r20140413.tar.gz && tar -xaf trinityrnaseq_r20140413.tar.gz && rm trinityrnaseq_r20140413.tar.gz ;\
    cd trinityrnaseq_r20140413 ;\
    make && ln -f -s `pwd`/* /usr/local/bin/


#install fastqc
RUN wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.10.1.zip && unzip fastqc_v0.10.1.zip && rm fastqc_v0.10.1.zip && chmod +x FastQC/fastqc && ln -f -s `pwd`/FastQC/* /usr/local/bin/

RUN apt-get upgrade -y -q && apt-get clean

# some tools taken from https://github.com/thierrymarianne/zen-cmd/blob/master/Dockerfile
RUN apt-get install -y -q vim htop locate && git clone git://git.code.sf.net/p/tmux/tmux-code /opt/src/tmux-code && apt-get clean ;\
    cd /opt/src/tmux-code ;\
    git fetch --all && git checkout tags/1.9 && apt-get install -y -q libncurses5-dev libevent-dev && apt-get install -y -q  && sh autogen.sh && ./configure --prefix=/opt/local/tmux && make && make install && ln -s /opt/local/tmux/bin/tmux /usr/bin ;\
    apt-get clean

# repos for python 3.3
RUN apt-get install python-software-properties -y -q && add-apt-repository ppa:fkrull/deadsnakes -y && apt-get update && apt-get install python3.3 zip python-pip -y -q && apt-get clean






#RUN apt-get install libcairo2-dev libgd2-xpm-dev  libpango1.0-dev gtk+2.0 libgnomecanvas2-dev libgnomeui-dev libnotify-dev libglade2-dev graphviz libnet-libidn-perl uuid-dev libdb-dev libmysqlclient-dev -y -q ;\
#    fab -f fabfile.py -H localhost install_biolinux:libraries && apt-get clean

#RUN perl -pi -e 's/install --upgrade \{1\}/install --upgrade \{1\} --allow-unverified \{1\} --allow-external \{1\}/' fabfile.py

#RUN fab -f fabfile.py -H localhost install_libraries:r
#RUN pip install -U cython;
#RUN fab -f fabfile.py -H localhost install_biolinux:libraries

#RUN pip install fabric
#RUN df -h
#RUN fab -f fabfile.py -H localhost install_biolinux:custom





#RUN fab -f fabfile.py -H localhost install_libraries:perl


#RUN pip install --upgrade pip
##sudo bash -c "pip install --allow-unverified Pyrex --allow-external Pyrex --upgrade Pyrex"
## fixes problem with pyrex
#RUN  git pull
## hopefully fixed problem with Pybedtools
#RUN pip install PIL --allow-unverified PIL --allow-external PIL; pip install ; pip install pypdf --allow-unverified pypdf --allow-external pypdf
#RUN git pull; perl -pi -e 's/-\sPIL/#- PIL# not in pypi/' config/python-libs.yaml ;  perl -pi -e 's/-\spypdf/#- pypdf# not in pypi/' config/python-libs.yaml

#RUN fab -f fabfile.py -H localhost install_libraries:python && apt-get clean

#RUN fab -f fabfile.py -H localhost install_libraries:r
#RUN fab -f fabfile.py -H localhost install_libraries:ruby
