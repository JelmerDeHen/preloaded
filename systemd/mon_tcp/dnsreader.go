package main

import (
	"encoding/json"
	"fmt"
	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
	"github.com/google/gopacket/pcap"
	"io/ioutil"
	"os"
	"time"
)

func main() {
	if len(os.Args) != 3 {
		fmt.Printf("%s <pcap> <out>\n", os.Args[0])
		return
	}
	in := os.Args[1]
	out := os.Args[2]

	if _, err := os.Stat(in); os.IsNotExist(err) {
		fmt.Printf("Pcap file %s does not exist\n", in)
		return
	}

	if handle, err := pcap.OpenOffline(in); err != nil {
		panic(err)
	} else {
		packetSource := gopacket.NewPacketSource(handle, handle.LinkType())
		for packet := range packetSource.Packets() {
			handlePacket(packet) // Do something with a packet here.
		}
	}
	bits, err := json.MarshalIndent(queries, "", "\t")
	if err != nil {
		panic(err)
	}
	err = ioutil.WriteFile(out, bits, 0644)
	if err != nil {
		panic(err)
	}
}

type query struct {
	Ts time.Time
	// From IP layer
	SrcIP string
	DstIP string
	//
	Name  string
	Type  string
	Class string

	Proto string
}

var queries []*query

func handlePacket(p gopacket.Packet) {

	pkg := &query{}
	fmt.Printf("%+v\n", p.Metadata())
	//fmt.Println(p.Metadata().Timestamp)
	pkg.Ts = p.Metadata().Timestamp

	ipLayer := p.Layer(layers.LayerTypeIPv4)
	if ipLayer != nil {
		ip, _ := ipLayer.(*layers.IPv4)
		//fmt.Printf("%+v\n", ip)
		//Version:4 IHL:5 TOS:0 Length:60 Id:54321 Flags: FragOffset:0 TTL:245 Protocol:UDP Checksum:45096 SrcIP:10.0.10.1 DstIP:10.0.10.2
		// SrcIP/DstIP = net.IP
		pkg.SrcIP = ip.SrcIP.String()
		pkg.DstIP = ip.DstIP.String()
	}

	tcpLayer := p.Layer(layers.LayerTypeTCP)
	if tcpLayer != nil {
		pkg.Proto = "TCP"
	}
	udpLayer := p.Layer(layers.LayerTypeUDP)
	if udpLayer != nil {
		pkg.Proto = "UDP"
	}

	dnsLayer := p.Layer(layers.LayerTypeDNS)
	if dnsLayer != nil {
		//fmt.Printf("%+v\n", dnsLayer)
		dns, _ := dnsLayer.(*layers.DNS)
		// Name, Type, Class
		for _, question := range dns.Questions {
			pkg.Name = string(question.Name)
			pkg.Class = question.Class.String()
			pkg.Type = question.Type.String()
			storeQuestion(pkg)
		}
	}
}
func storeQuestion(q *query) {
	queries = append(queries, q)
}
