FROM alanpeng/oracle-jdk6 as jdk6

WORKDIR /root

# Install dependencies
RUN yum install -y git wget unzip zip

# Install SDKMan
RUN curl -s "https://get.sdkman.io" | bash

# Download ivy
RUN wget https://archive.apache.org/dist/ant/ivy/2.4.0/apache-ivy-2.4.0-bin-with-deps.zip
RUN unzip apache-ivy-2.4.0-bin-with-deps.zip

# Download ExcelCompare
RUN git clone https://github.com/na-ka-na/ExcelCompare.git

RUN source "/root/.sdkman/bin/sdkman-init.sh" \
	&& sdk install ant 1.9.15 \
	&& echo done

# Build ExcelCompare
WORKDIR /root/ExcelCompare/
RUN mkdir /root/ExcelCompare/ivy
RUN cp /root/apache-ivy-2.4.0/ivy-2.4.0.jar /root/ExcelCompare/ivy/ivy.jar
ADD lib lib
ENV JAVA_HOME /root/jdk/jdk1.6.0_45
RUN source "/root/.sdkman/bin/sdkman-init.sh" \
	&& ant clean test \
	&& ant clean build

# Configure ExcelCompare
RUN unzip -o ExcelCompare-0.6.1.zip
RUN chmod +x /root/ExcelCompare/bin/excel_cmp

# Actions Runner
FROM myoung34/github-runner as runner

# Copy Artifacts
COPY --from=jdk6 /root/jdk /root/jdk
COPY --from=jdk6 /root/ExcelCompare /root/ExcelCompare

# Set Environment
ENV PATH=$PATH:/root/jdk/jdk1.6.0_45/bin
ENV JAVA16_HOME /root/jdk/jdk1.6.0_45
ENV PATH=${PATH}:/root/ExcelCompare/bin
