package com.example;

import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class Publisher {

    private final String exchangeName;

    private final Connection connection;

    @Autowired
    public Publisher(@Value("${rabbitmq.exchangeName}") String exchangeName, Connection connection) {
        this.exchangeName = exchangeName;
        this.connection = connection;
    }

    public void publish(String message, String topicName) {
        if (message == null) {
            return;
        }
        try {
            Channel channel = connection.createChannel();
            channel.basicPublish(exchangeName, topicName, null, message.getBytes());
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.println(" [x] Sent '" + message + "'");
    }
}
