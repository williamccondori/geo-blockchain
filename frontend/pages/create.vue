<template>
  <section>
    <h1 class="mb-1">CREACIÓN DE REGISTROS</h1>
    <el-divider />
    <el-card class="mb-1">
      <h1 class="mb-1">POLÍGONOS TEMPORALES</h1>
      <el-table :data="temporalLayers" style="width: 100%" size="mini">
        <el-table-column label="CÓDIGO">
          <template slot-scope="scope">
            <el-tag size="mini">{{ scope.row.id }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="FECHA DE CREACIÓN">
          <template slot-scope="scope">
            {{ scope.row.createdAt | date }}
          </template>
        </el-table-column>
        <el-table-column align="right">
          <template slot-scope="scope">
            <el-button
              size="mini"
              type="primary"
              @click="handleCreate(scope.row.id)"
            >
              <span>GUARDAR</span>
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    <el-card>
      <div id="map" />
    </el-card>
    <el-drawer
      :visible="createVisible"
      title="GUARDAR REGISTRO"
      @close="handleClose"
    >
      <el-main>
        <el-form ref="formRef" :model="form" :rules="formRules">
          <el-form-item label="NOMBRE:" prop="name">
            <el-input v-model="form.name" type="name" />
          </el-form-item>
          <el-form-item label="APELLIDO:" prop="lastName">
            <el-input v-model="form.lastName" type="lastName" />
          </el-form-item>
          <el-form-item label="N° DE CONTRATO:" prop="contractNumber">
            <el-input v-model="form.contractNumber" type="contractNumber" />
          </el-form-item>
          <el-form-item>
            <el-button type="success" class="block" @click="handleSubmit">
              GUARDAR
            </el-button>
          </el-form-item>
        </el-form>
      </el-main>
    </el-drawer>
  </section>
</template>

<script>
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import "leaflet-draw/dist/leaflet.draw.css";
import "leaflet-draw/dist/leaflet.draw.js";

const form = {
  name: "",
  lastName: "",
  contractNumber: "",
};

const formRules = {
  name: [{ required: true, message: "INGRESE SU NOMBRE" }],
  lastName: [{ required: true, message: "INGRESE SU APELLIDO" }],
  contractNumber: [{ required: true, message: "INGRESE SU N° DE CONTRATO" }],
};

export default {
  name: "CreatePage",
  data() {
    return {
      form: { ...form },
      formRules,
      map: null,
      leafletIdSelected: null,
      temporalLayers: [],
      createVisible: false,
      editableLayer: null,
      // Bloackchain
      account: null,
      registersContract: {},
    };
  },
  async mounted() {
    if (!this.map) {
      await this.initMap();
    }
    await this.initDApp();
  },
  methods: {
    async initMap() {
      const map = L.map("map").setView([-12.5811764, -69.1565787], 12);
      // Add base map.
      const baseLayer = L.tileLayer(
        "https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}{r}.png"
      );
      map.addLayer(baseLayer);

      const baseLayers = {
        "STADIA.OSMBRIGHT": baseLayer,
        "STADIA.ALIDADESMOOTHDARK": L.tileLayer(
          "https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png"
        ),
        "STADIA.ALIDADESMOOTH": L.tileLayer(
          "https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png"
        ),
        "GOOGLE.MAPS": L.tileLayer(
          "https://mt1.google.com/vt/lyrs=r&x={x}&y={y}&z={z}"
        ),
        "GOOGLE.HYBRID": L.tileLayer(
          "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}"
        ),
        "GOOGLE.ROADS": L.tileLayer(
          "https://mt1.google.com/vt/lyrs=h&x={x}&y={y}&z={z}"
        ),
      };

      // Add regions layer.
      let response = await fetch("Departamentos.geojson");
      let responseGeojson = await response.json();
      const regionLayer = L.geoJSON(responseGeojson, {
        style: {
          color: "lightblue",
          weight: 1,
          fillColor: "lightblue",
          fillOpacity: 0.05,
        },
      });

      // Add district layer.
      response = await fetch("Provincias.geojson");
      responseGeojson = await response.json();
      const provinceLayer = L.geoJSON(responseGeojson, {
        style: {
          color: "green",
          weight: 1,
          fillColor: "green",
          fillOpacity: 0.05,
        },
      });

      // Add district layer.
      response = await fetch("Distritos.geojson");
      responseGeojson = await response.json();
      const districtLayer = L.geoJSON(responseGeojson, {
        style: {
          color: "orange",
          weight: 1,
          fillColor: "orange",
          fillOpacity: 0.05,
        },
      });

      const overlayMaps = {
        DEPARTAMENTOS: regionLayer,
        PROVINCIAS: provinceLayer,
        DISTRITOS: districtLayer,
      };
      L.control.layers(baseLayers, overlayMaps).addTo(map);

      this.editableLayer = new L.FeatureGroup();
      map.addLayer(this.editableLayer);

      new L.Control.Draw({
        draw: {
          circle: false,
          marker: false,
          polyline: false,
          rectangle: false,
          circlemarker: false,
          polygon: {
            allowIntersection: false,
            showArea: true,
            metric: true,
            shapeOptions: {
              color: "purple",
              weight: 3,
            },
          },
        },
        edit: {
          featureGroup: this.editableLayer,
          remove: true,
        },
      }).addTo(map);

      map.on("draw:created", ({ layer }) => {
        this.editableLayer.addLayer(layer);
        this.temporalLayers.push({
          id: layer._leaflet_id,
          createdAt: new Date().toISOString(),
        });
      });
      map.on("draw:deleted", ({ layers }) => {
        layers.eachLayer((layer) => {
          this.editableLayer.removeLayer(layer);
          this.temporalLayers = this.temporalLayers.filter(
            (x) => x.id !== layer._leaflet_id
          );
        });
      });

      L.control.scale().addTo(map);

      this.map = map;
    },
    async initDApp() {
      if (window.ethereum) {
        // Accessing the provider through the ethereum object.
        const web3Provider = window.ethereum;
        const accounts = await web3Provider.request({
          method: "eth_requestAccounts",
        });
        this.account = accounts[0];
        // Load contract.
        const contracts = {};
        const response = await fetch("/RegistersContract.json");
        // eslint-disable-next-line no-undef
        contracts.RegistersContract = TruffleContract(await response.json());
        contracts.RegistersContract.setProvider(web3Provider);
        this.registersContract = await contracts.RegistersContract.deployed();
      } else {
        this.$message.error(
          "NO SE HA ENCONTRADO LA EXTENSIÓN METAMASK, INSTALALA PARA PODER USAR LA APLICACIÓN"
        );
      }
    },
    handleCreate(leafletId) {
      this.leafletIdSelected = leafletId;
      this.createVisible = true;
    },
    handleClose() {
      this.resetFields();
      this.createVisible = false;
    },
    handleSubmit() {
      this.$refs.formRef.validate(async (valid) => {
        if (valid) {
          try {
            const layers = this.editableLayer.getLayers();

            // Remove from map.
            const layerSelected = layers.find(
              (x) => x._leaflet_id === this.leafletIdSelected
            );
            this.editableLayer.removeLayer(layerSelected);

            // Remove from temporal layers.
            this.temporalLayers = this.temporalLayers.filter(
              (x) => x.id !== this.leafletIdSelected
            );

            // Get GeoJSON from layer.
            const geojson = layerSelected.toGeoJSON();

            // Add properties to GeoJSON.
            geojson.properties = {
              name: this.form.name,
              lastName: this.form.lastName,
              contractNumber: this.form.contractNumber,
            };

            // Create registry.
            const result = await this.registersContract.createRegister(
              this.form.name,
              this.form.lastName,
              this.form.contractNumber,
              JSON.stringify(geojson),
              this.$auth.user.email,
              {
                from: this.account,
              }
            );
            console.log(result);
            this.resetFields();
            this.createVisible = false;
            this.$message.success("LA OPERACIÓN SE HA COMPLETADO EXITOSAMENTE");
          } catch (e) {
            console.error(e);
            this.$message.error(
              "SE HA ENCONTRADO ERRORES AL REALIZAR LA OPERACIÓN"
            );
          }
        }
      });
    },
    resetFields() {
      this.form = { ...form };
      this.leafletIdSelected = null;
      this.$refs.formRef.resetFields();
    },
  },
};
</script>
