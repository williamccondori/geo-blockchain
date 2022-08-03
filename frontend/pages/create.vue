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

import { v4 as uuidv4 } from "uuid";
import { mapActions } from "vuex";

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
    };
  },
  mounted() {
    this.initMap();
  },
  methods: {
    ...mapActions(["createRegistry"]),
    initMap() {
      const map = L.map("map").setView([-0.23, -78.5], 13);
      // Add base map.
      map.addLayer(
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
          attribution: "&copy; WILLIAM CONDORI QUISPE",
        })
      );

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
              color: "blue",
              weight: 1,
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
    handleCreate(leafletId) {
      this.leafletIdSelected = leafletId;
      this.createVisible = true;
    },
    handleClose() {
      this.resetFields();
      this.createVisible = false;
    },
    handleSubmit() {
      this.$refs.formRef.validate((valid) => {
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
            const registry = {
              id: uuidv4(),
              name: this.form.name,
              lastName: this.form.lastName,
              contractNumber: this.form.contractNumber,
              geojson: geojson,
            };
            this.createRegistry(registry);

            this.resetFields();
            this.createVisible = false;
            this.$message.success("LA OPERACIÓN SE HA COMPLETADO EXITOSAMENTE");
          } catch (_) {
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
