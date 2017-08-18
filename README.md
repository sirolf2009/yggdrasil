# Yggdrasil 
![Yggdrasil](https://upload.wikimedia.org/wikipedia/commons/b/b3/Om_Yggdrasil_by_Frølich.jpg)
Yggdrasil is a set of tools for machine learning. It is named after yggdrasil from the norse mythologies, the tree that connects all worlds. Likewise, the modules are all named after norse gods.

This project is still very young and everything is subject to change (a database may be swapped out for another depending on how well I've slept, though normally these changes get reverted the day after)

## Freyr - God of fertility - Data Collector
Collects data and throws it into an InfluxDB database

## Vor - Godess of wistdom - Machine Learning
Collects Freyrs data and applies machine learning on it using Deeplearning4J
Preferably clusterable

## Odin - Father of all gods - Monitoring
Collects heartbeats and retrieves docker container health

## Kvasir - God of inspiration - Charting 
An application/library to browse and chart data. Inspired by tableau

## Sif - Godess of harvest - Data Retrieval/Manipulation
Defines ways of getting data for other modules
