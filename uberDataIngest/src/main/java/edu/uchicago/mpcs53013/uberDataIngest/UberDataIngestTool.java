package edu.uchicago.mpcs53013.uberDataIngest;

import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;

public class UberDataIngestTool {
    public static void main(String[] args) {

        // Get the three necessary arguments from user
        if (args.length != 3) {
            throw new IllegalArgumentException("Need 3 arguments: \n" +
                    "    (1) input directory path (in local file system), \n" +
                    "    (2) year to ingest (2014 or 2015), \n" +
                    "    (3) output directory path (in HDFS).");
        }
        String inputDirectory = args[0];
        int year = Integer.parseInt(args[1]);
        String outputDirectory = args[2];

        // Ingest the raw data, note that year 2014 and 2015 have different data formats
        try {
            Configuration conf = new Configuration();
            conf.addResource(new Path("/etc/hadoop/conf/core-site.xml"));
            conf.addResource(new Path("/etc/hadoop/conf/hdfs-site.xml"));
            final Configuration finalConf = new Configuration(conf);

            UberDataProcessor processor = null;
            if (year == 2014) {
                processor = new UberData2014Processor(inputDirectory, outputDirectory, finalConf);
            } else if (year == 2015) {
                processor = new UberData2015Processor(inputDirectory, outputDirectory, finalConf);
            } else {
                throw new IllegalArgumentException("Only support two formats of uber raw data: year 2014 or 2015.");
            }
            processor.process();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}



