package edu.uchicago.mpcs53013.uberDataIngest;

import java.io.File;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.SequenceFile.CompressionType;
import org.apache.hadoop.io.SequenceFile.Writer;
import org.apache.thrift.TSerializer;
import org.apache.thrift.protocol.TBinaryProtocol;

public abstract class UberDataProcessor {

    final String inputDirectory;
    final String outputDirectory;
    final Configuration finalConf;
    final int year;

    final IntWritable one;
    final TSerializer ser;
    final Writer writer;

    // Constructor
    UberDataProcessor(String inputDirectory, String outputDirectory, Configuration finalConf, int year) throws IOException {
        this.inputDirectory = inputDirectory;
        this.outputDirectory = outputDirectory;
        this.finalConf = finalConf;
        this.year = year;

        one = new IntWritable(1);
        ser = new TSerializer(new TBinaryProtocol.Factory());
        writer = SequenceFile.createWriter(finalConf,
                Writer.file(new Path(outputDirectory + "/uber" + year)),
                Writer.keyClass(IntWritable.class),
                Writer.valueClass(BytesWritable.class),
                Writer.compression(CompressionType.NONE));
    }

    // Process a directory
    void process() throws IOException {
        File directory = new File(inputDirectory);
        File[] files = directory.listFiles();
        if (files == null) {
            return;
        }
        for (File file : files) {
            if (shouldProcess(file)) {
                processFile(file);
            }
        }
    }

    // Process a file
    private void processFile(File file) throws IOException {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file)))) {
            String line;
            while ((line = br.readLine()) != null) {
                processLine(line);
            }
        }
    }

    // Process a line
    abstract void processLine(String line) throws IOException;

    // Determine if a file should be processed
    abstract boolean shouldProcess(File file);

}



