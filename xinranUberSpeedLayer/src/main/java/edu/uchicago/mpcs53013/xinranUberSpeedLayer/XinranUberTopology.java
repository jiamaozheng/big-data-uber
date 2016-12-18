package edu.uchicago.mpcs53013.xinranUberSpeedLayer;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import org.apache.commons.lang.StringUtils;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.util.Bytes;

import backtype.storm.LocalCluster;
import backtype.storm.StormSubmitter;
import backtype.storm.generated.AlreadyAliveException;
import backtype.storm.generated.AuthorizationException;
import backtype.storm.generated.InvalidTopologyException;
import backtype.storm.spout.SchemeAsMultiScheme;
import backtype.storm.task.TopologyContext;
import backtype.storm.topology.BasicOutputCollector;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.TopologyBuilder;
import backtype.storm.topology.base.BaseBasicBolt;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Tuple;
import backtype.storm.tuple.Values;
import backtype.storm.utils.Utils;
import storm.kafka.KafkaSpout;
import storm.kafka.SpoutConfig;
import storm.kafka.StringScheme;
import storm.kafka.ZkHosts;

public class XinranUberTopology {

	static class ValidateUberEventBolt extends BaseBasicBolt {

		Pattern locationPattern;
		Pattern yearPattern;
		Pattern monthPattern;
		Pattern dayPattern;
		Pattern hourPattern;
		Pattern pickupPattern;

		@Override
		public void prepare(Map stormConf, TopologyContext context) {
			locationPattern = Pattern.compile("<location>(.*)</location>");
			yearPattern = Pattern.compile("<year>(.*)</year>");
			monthPattern = Pattern.compile("<month>(.*)</month>");
			dayPattern = Pattern.compile("<day>(.*)</day>");
			hourPattern = Pattern.compile("<hour>(.*)</hour>");
			pickupPattern = Pattern.compile("<pickup>(.*)</pickup>");
			super.prepare(stormConf, context);
		}

		@Override
		public void execute(Tuple tuple, BasicOutputCollector collector) {

			String event = tuple.getString(0);

			// Validate location
			Matcher locationMatcher = locationPattern.matcher(event);
			if (!locationMatcher.find()) {
				return;
			}
			String location = locationMatcher.group(1);

			// Validate year
			Matcher yearMatcher = yearPattern.matcher(event);
			if (!yearMatcher.find()) {
				return;
			}
			String year = yearMatcher.group(1);

			// Validate month
			Matcher monthMatcher = monthPattern.matcher(event);
			if (!monthMatcher.find()) {
				return;
			}
			String month = monthMatcher.group(1);

			// Validate day
			Matcher dayMatcher = dayPattern.matcher(event);
			if (!dayMatcher.find()) {
				return;
			}
			String day = dayMatcher.group(1);

			// Validate hour
			Matcher hourMatcher = hourPattern.matcher(event);
			if (!hourMatcher.find()) {
				return;
			}
			String hour = hourMatcher.group(1);

			// Validate pickup counts
			Matcher pickupMatcher = pickupPattern.matcher(event);
			if (!pickupMatcher.find()) {
				return;
			}
			String pickup = pickupMatcher.group(1);

			collector.emit(new Values(location, year, month, day, hour, pickup));

		}

		@Override
		public void declareOutputFields(OutputFieldsDeclarer declarer) {
			declarer.declare(new Fields("location", "year", "month", "day", "hour", "pickup"));
		}

	}

	static class ConvertUberEventBolt extends BaseBasicBolt {

		@Override
		public void execute(Tuple input, BasicOutputCollector collector) {

			String location = input.getStringByField("location");
			String year = input.getStringByField("year");
			String month = input.getStringByField("month");
			String day = input.getStringByField("day");
			String hour = input.getStringByField("hour");
			String pickup = input.getStringByField("pickup");

			// Determine if the event is to add a new record, or to reset existing record
			if (year.equalsIgnoreCase("-1")) {
				collector.emit(new Values(location, "-1", "-1", "-1"));
			} else {
				try {
					String str = year + "/" + month + "/" + day;
					Date date = new SimpleDateFormat("yyyy/M/d").parse(str);
					Calendar c = Calendar.getInstance();
					c.setTime(date);
					int dayOfWeek_int = c.get(Calendar.DAY_OF_WEEK) - 1;
					String dayOfWeek = Integer.toString(dayOfWeek_int);
					collector.emit(new Values(location, dayOfWeek, hour, pickup));
				} catch (Exception e) {
					e.printStackTrace();
				}
			}

		}

		@Override
		public void declareOutputFields(OutputFieldsDeclarer declarer) {
			declarer.declare(new Fields("location", "dayOfWeek", "hour", "pickup"));
		}

	}

	static class UpdateUberHBaseBolt extends BaseBasicBolt {

		private org.apache.hadoop.conf.Configuration conf;
		private Connection hbaseConnection;

		@Override
		public void prepare(Map stormConf, TopologyContext context) {
			try {
				conf = HBaseConfiguration.create();
				conf.set("hbase.zookeeper.property.clientPort", "2181");
				conf.set("hbase.zookeeper.quorum", StringUtils.join((List<String>)(stormConf.get("storm.zookeeper.servers")), ","));
				String znParent = (String) stormConf.get("zookeeper.znode.parent");
				if (znParent == null)
					znParent = new String("/hbase");
				conf.set("zookeeper.znode.parent", znParent);
				hbaseConnection = ConnectionFactory.createConnection(conf);
			} catch (IOException e) {
				e.printStackTrace();
			}
			super.prepare(stormConf, context);
		}

		@Override
		public void cleanup() {
			try {
				hbaseConnection.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
			super.cleanup();
		}

		@Override
		public void execute(Tuple input, BasicOutputCollector collector) {
			try {
				String location = input.getStringByField("location");
				String dayOfWeek = input.getStringByField("dayOfWeek");
				String hour = input.getStringByField("hour");
				String pickup = input.getStringByField("pickup");

				Table table = hbaseConnection.getTable(TableName.valueOf("xinran_uber_2015_plot_speed"));

				String guiData_new = null;
				if (dayOfWeek.equalsIgnoreCase("-1")) {  // reset
					guiData_new = "|";
				} else {  // append
					Get get = new Get(Bytes.toBytes(location));
					Result result = table.get(get);
					byte[] old = result.getValue(Bytes.toBytes("uber2015"), Bytes.toBytes("guiData"));
					String guiData_old = Bytes.toString(old);
					if (guiData_old == null) {
						guiData_old = "";
					}
					StringBuilder sb = new StringBuilder();
					sb.append(guiData_old);
					sb.append(dayOfWeek);
					sb.append(",");
					sb.append(hour);
					sb.append(",");
					sb.append(pickup);
					sb.append("|");
					guiData_new = sb.toString();
				}

				Put put = new Put(Bytes.toBytes(location));
				put.addColumn(Bytes.toBytes("uber2015"), Bytes.toBytes("guiData"), Bytes.toBytes(guiData_new));
				table.put(put);

				table.close();

			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		@Override
		public void declareOutputFields(OutputFieldsDeclarer declarer) {

		}

	}

	public static void main(String[] args) throws AlreadyAliveException, InvalidTopologyException, AuthorizationException {
		Map stormConf = Utils.readStormConfig();
		String zookeepers = StringUtils.join((List<String>)(stormConf.get("storm.zookeeper.servers")), ",");
		System.out.println(zookeepers);
		ZkHosts zkHosts = new ZkHosts(zookeepers);

		SpoutConfig kafkaConfig = new SpoutConfig(zkHosts, "xinran-uber-events", "/xinran-uber-events", "uber_id");
		kafkaConfig.scheme = new SchemeAsMultiScheme(new StringScheme());
		kafkaConfig.zkRoot = "/xinran-uber-events";
		KafkaSpout kafkaSpout = new KafkaSpout(kafkaConfig);

		TopologyBuilder builder = new TopologyBuilder();

		builder.setSpout("raw-uber-events", kafkaSpout, 1);
		builder.setBolt("validate-uber-event", new ValidateUberEventBolt(), 1).shuffleGrouping("raw-uber-events");
		builder.setBolt("convert-uber-event", new ConvertUberEventBolt(), 1).shuffleGrouping("validate-uber-event");
		builder.setBolt("update-uber-hbase", new UpdateUberHBaseBolt(), 1).shuffleGrouping("convert-uber-event");

		Map conf = new HashMap();
		conf.put(backtype.storm.Config.TOPOLOGY_WORKERS, 2);

		if (args != null && args.length > 0) {
			StormSubmitter.submitTopology(args[0], conf, builder.createTopology());
		} else {
			conf.put(backtype.storm.Config.TOPOLOGY_DEBUG, true);
			LocalCluster cluster = new LocalCluster(zookeepers, 2181L);
			cluster.submitTopology("xinran-uber-topology", conf, builder.createTopology());
		} 
	} 
}


