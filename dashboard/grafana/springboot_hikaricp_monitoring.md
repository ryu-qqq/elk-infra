<details>
<summary> HikariCP 커넥션 풀 모니터링 </summary>
# 📌 HikariCP 커넥션 풀 모니터링

## 📊 PromQL 쿼리
### **1. 현재 활성(Active) 상태인 커넥션 개수**
```promql
hikaricp_connections_active{instance="$instance", application="$application", pool="$hikaricp"}
```
✔ **현재 사용 중인(Active) DB 커넥션 개수.**  
✔ **애플리케이션이 실제로 DB에 연결하여 쿼리를 실행하고 있는 커넥션 수.**  
✔ **이 값이 지속적으로 최대 풀 크기에 근접하면, 커넥션 풀 크기를 늘려야 할 수도 있음.**  
✔ **급격한 증가가 발생하면, DB 부하를 줄이기 위한 최적화 필요.**

### **2. 현재 유휴(Idle) 상태인 커넥션 개수**
```promql
hikaricp_connections_idle{instance="$instance", application="$application", pool="$hikaricp"}
```
✔ **사용되지 않고 풀에서 대기 중인(Idle) 커넥션 개수.**  
✔ **적절한 Idle 커넥션 유지가 중요하며, 너무 많으면 리소스 낭비, 너무 적으면 응답 지연 발생 가능.**  
✔ **Idle 개수가 적다면, 새로운 커넥션 생성 부담이 증가하여 성능 저하 가능.**  
✔ **Idle 개수가 지나치게 많다면, 비효율적인 커넥션 유지로 인해 DB 리소스 낭비 가능.**

### **3. 대기(Pending) 중인 요청 개수**
```promql
hikaricp_connections_pending{instance="$instance", application="$application", pool="$hikaricp"}
```
✔ **현재 사용 가능한 커넥션이 없어서 대기 중인(Pending) 요청 개수.**  
✔ **이 값이 높아지면, 애플리케이션이 필요한 만큼 커넥션을 확보하지 못하고 있다는 의미.**  
✔ **DB 커넥션 풀 크기가 작거나, 쿼리 응답 시간이 길어지고 있는 문제 가능성 있음.**  
✔ **Pending 상태가 지속되면, 애플리케이션 성능 저하 및 장애 발생 가능성 증가.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `hikaricp_connections_active` | 현재 사용 중인(Active) 커넥션 개수 |
| `hikaricp_connections_idle` | 현재 유휴(Idle) 상태인 커넥션 개수 |
| `hikaricp_connections_pending` | 현재 대기(Pending) 중인 요청 개수 |

📌 **HikariCP는 DB 커넥션을 효율적으로 관리하지만, 적절한 풀 크기 조정이 중요함.**  
📌 **Active 커넥션이 많다면, 쿼리 최적화 또는 풀 크기 증가를 고려해야 함.**  
📌 **Idle 커넥션이 너무 적으면, 요청이 몰릴 때 빠른 응답이 어려울 수 있음.**  
📌 **Pending 요청이 많아지면, 커넥션 부족으로 인해 애플리케이션이 지연될 수 있음.**

---

## 🔥 **왜 이 3개의 메트릭이 중요한가?**
✔ **Active 커넥션만 모니터링하면 안 되는 이유**
- Active 커넥션이 많다고 해서 반드시 문제가 있는 것은 아님.
- Idle 커넥션과 Pending 요청을 함께 분석해야 실제 병목 현상을 파악할 수 있음.

✔ **Idle 커넥션을 모니터링해야 하는 이유**
- Idle 커넥션이 많으면 비효율적인 리소스 관리로 DB 성능 저하 가능성이 있음.
- 반대로 너무 적으면 새로운 요청이 대기(Pending) 상태로 넘어갈 가능성이 높아짐.

✔ **Pending 요청이 많으면 즉시 대응해야 하는 이유**
- Pending 요청이 많으면, 애플리케이션이 DB에 접근하지 못하고 지연되는 상황 발생.
- 일반적으로 **풀 크기 조정, DB 성능 최적화, 커넥션 타임아웃 설정 변경** 등을 검토해야 함.

---

## 📌 **Grafana에서 HikariCP 모니터링 대시보드 설정**
### 🖥️ **패널 설정**
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** 커넥션 개수 (Count)
- **PromQL 쿼리:**
    - **현재 활성(Active) 상태인 커넥션 개수**
      ```promql
      hikaricp_connections_active{instance="$instance", application="$application", pool="$hikaricp"}
      ```
    - **현재 유휴(Idle) 상태인 커넥션 개수**
      ```promql
      hikaricp_connections_idle{instance="$instance", application="$application", pool="$hikaricp"}
      ```
    - **현재 대기(Pending) 중인 요청 개수**
      ```promql
      hikaricp_connections_pending{instance="$instance", application="$application", pool="$hikaricp"}
      ```

### 🚨 **임계값(Threshold) 설정**
- **Active 커넥션이 풀 크기에 가까워짐** → 🟠 **주의 (쿼리 성능 저하 가능성)**
- **Idle 커넥션이 너무 적음 (예: 0~1개 수준)** → 🔴 **위험 (새로운 요청 대기 가능성 증가)**
- **Pending 요청이 지속적으로 증가** → 🟠 **주의 (DB 커넥션 부족 가능성, 풀 크기 조정 필요)**

📌 **DB 부하 테스트를 통해 적절한 풀 크기(HikariCP maxPoolSize)를 설정하는 것이 중요함!**  
📌 **Pending 요청이 많아지면, DB가 병목 상태일 가능성이 높으므로 쿼리 최적화 또는 커넥션 풀 크기 조정 필요!**

---

## ✅ **결론**
✔ **Active, Idle, Pending 커넥션을 함께 보면 DB 커넥션 풀의 실제 사용 상태를 파악 가능!**  
✔ **Active 커넥션이 많아지면 풀 크기를 조정하거나 쿼리 최적화를 고려해야 함!**  
✔ **Idle 커넥션이 너무 적으면 새로운 요청을 빠르게 처리하지 못할 수 있음!**  
✔ **Pending 요청이 많아지면 DB 병목 현상이 발생할 가능성이 큼, 즉시 대응해야 함!**  
✔ **Grafana에서 HikariCP 모니터링을 통해 DB 성능을 최적화하고 안정적인 서비스 운영 가능!**

</details>


<details>
<summary> HikariCP 커넥션 성능 모니터링 </summary>

# 📌 HikariCP 커넥션 성능 모니터링

## 📊 PromQL 쿼리
### **1. 평균 커넥션 생성 시간 (Connection Creation Time)**
```promql
hikaricp_connections_creation_seconds_sum{instance="$instance", application="$application", pool="$hikaricp"} / 
hikaricp_connections_creation_seconds_count{instance="$instance", application="$application", pool="$hikaricp"}
```
✔ **새로운 DB 커넥션을 생성하는 데 걸린 평균 시간(초).**  
✔ **커넥션 풀에 여유가 없어 새로운 커넥션을 생성해야 하는 경우 증가할 수 있음.**  
✔ **DB 서버의 성능 문제, 네트워크 지연, 인증 속도 저하 등의 원인으로 지연될 수 있음.**  
✔ **커넥션 풀 크기 조정을 통해 불필요한 커넥션 생성 지연을 방지할 수 있음.**

### **2. 평균 커넥션 사용 시간 (Connection Usage Time)**
```promql
hikaricp_connections_usage_seconds_sum{instance="$instance", application="$application", pool="$hikaricp"} / 
hikaricp_connections_usage_seconds_count{instance="$instance", application="$application", pool="$hikaricp"}
```
✔ **커넥션이 사용된 총 시간의 평균값(초).**  
✔ **애플리케이션이 커넥션을 얼마나 오랫동안 유지하는지 파악 가능.**  
✔ **쿼리 실행 시간이 길어지거나, 트랜잭션이 적절히 종료되지 않으면 값이 증가할 수 있음.**  
✔ **이 값이 지나치게 높다면, 쿼리 최적화 또는 트랜잭션 관리가 필요함.**

### **3. 평균 커넥션 획득 시간 (Connection Acquire Time)**
```promql
hikaricp_connections_acquire_seconds_sum{instance="$instance", application="$application", pool="$hikaricp"} / 
hikaricp_connections_acquire_seconds_count{instance="$instance", application="$application", pool="$hikaricp"}
```
✔ **애플리케이션이 DB 커넥션을 풀에서 획득하는 데 걸리는 평균 시간(초).**  
✔ **커넥션 풀에서 즉시 사용 가능한 커넥션이 없다면, 이 값이 증가할 가능성이 높음.**  
✔ **커넥션 풀이 부족하면, 커넥션을 획득하기 위해 대기 시간이 길어질 수 있음.**  
✔ **값이 지속적으로 증가하면 커넥션 풀 크기를 늘리거나, 커넥션 반환이 적절히 이루어지는지 확인해야 함.**

---

## 🔍 설명
| **쿼리** | **설명** |
|----------|---------|
| `hikaricp_connections_creation_seconds` | 새로운 DB 커넥션을 생성하는 데 걸린 평균 시간 |
| `hikaricp_connections_usage_seconds` | 커넥션이 사용된 평균 시간 |
| `hikaricp_connections_acquire_seconds` | 커넥션 풀에서 커넥션을 가져오는 평균 시간 |

📌 **DB 커넥션을 관리하는 HikariCP의 성능을 최적화하려면 이 3가지 지표를 모니터링해야 함.**  
📌 **커넥션 생성 시간이 길어지면, 커넥션 풀 크기 조정 또는 DB 연결 속도 개선이 필요함.**  
📌 **커넥션 사용 시간이 길어지면, 긴 쿼리를 최적화하고 트랜잭션을 관리해야 함.**  
📌 **커넥션 획득 시간이 길어지면, 커넥션 풀이 부족하거나 리소스 경합이 발생할 가능성이 있음.**

---

## 🔥 **왜 이 3개의 메트릭이 중요한가?**
✔ **커넥션 생성 시간이 길면, 애플리케이션이 새로운 DB 연결을 생성하는 데 오랜 시간이 걸릴 수 있음.**
- 커넥션 풀이 부족하여 새로운 커넥션을 계속 생성해야 하는 경우 성능 저하 발생 가능.
- 네트워크 문제, DB 인증 지연 등의 원인으로 생성 시간이 증가할 수 있음.

✔ **커넥션 사용 시간이 길면, DB 리소스를 장시간 점유하여 성능 저하 가능.**
- 트랜잭션이 오래 유지되면 다른 요청이 블로킹될 가능성이 있음.
- 특정 쿼리가 병목을 유발할 가능성이 있어, 실행 시간 분석이 필요함.

✔ **커넥션 획득 시간이 길면, 애플리케이션의 응답 속도 저하 가능.**
- 풀 크기가 너무 작거나, 커넥션 반환이 원활하지 않다면 커넥션 획득 지연 발생 가능.
- 커넥션 풀 크기 조정 또는 커넥션 타임아웃 설정 검토 필요.

---

## 📌 **Grafana에서 HikariCP 성능 모니터링 대시보드 설정**
### 🖥️ **패널 설정**
- **패널 유형:** Line Chart
- **X축:** 시간 (Timestamp)
- **Y축:** 시간 (Seconds)
- **PromQL 쿼리:**
    - **평균 커넥션 생성 시간**
      ```promql
      hikaricp_connections_creation_seconds_sum{instance="$instance", application="$application", pool="$hikaricp"} / 
      hikaricp_connections_creation_seconds_count{instance="$instance", application="$application", pool="$hikaricp"}
      ```
    - **평균 커넥션 사용 시간**
      ```promql
      hikaricp_connections_usage_seconds_sum{instance="$instance", application="$application", pool="$hikaricp"} / 
      hikaricp_connections_usage_seconds_count{instance="$instance", application="$application", pool="$hikaricp"}
      ```
    - **평균 커넥션 획득 시간**
      ```promql
      hikaricp_connections_acquire_seconds_sum{instance="$instance", application="$application", pool="$hikaricp"} / 
      hikaricp_connections_acquire_seconds_count{instance="$instance", application="$application", pool="$hikaricp"}
      ```

### 🚨 **임계값(Threshold) 설정**
- **커넥션 생성 시간이 500ms 이상 지속** → 🟠 **주의 (커넥션 생성 최적화 필요)**
- **커넥션 사용 시간이 1초 이상 지속** → 🔴 **위험 (트랜잭션이 오래 유지됨, 쿼리 최적화 필요)**
- **커넥션 획득 시간이 200ms 이상 지속** → 🟠 **주의 (커넥션 풀 크기 조정 필요)**

📌 **DB 부하가 많은 경우, HikariCP 풀 크기 및 쿼리 성능을 점검해야 함!**  
📌 **응답 속도 저하를 방지하려면 커넥션 획득, 사용, 생성을 균형 있게 조정하는 것이 중요함!**

---

## ✅ **결론**
✔ **커넥션 생성, 사용, 획득 시간을 함께 모니터링하면 DB 성능 최적화 가능!**  
✔ **커넥션 생성이 오래 걸리면 네트워크 또는 DB 인증 문제 가능성 있음!**  
✔ **커넥션 사용 시간이 길어지면, 트랜잭션 관리 및 쿼리 최적화 필요!**  
✔ **커넥션 획득 시간이 길어지면, 커넥션 풀 크기 조정 또는 타임아웃 설정 필요!**  
✔ **Grafana에서 HikariCP 모니터링을 통해 DB 성능을 최적화하고 안정적인 서비스 운영 가능!**

📌 **이제 Grafana에서 HikariCP 성능 모니터링 대시보드를 설정하여 DB 성능 최적화를 진행하자! 🚀**

</details>