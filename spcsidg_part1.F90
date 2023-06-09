SUBROUTINE SPCSIDG_PART1 (YDGEOMETRY, YDDYN, KSPEC2V, KM, KMLOC, KSTA, KEND, PSDIVP, PSPDIVP)

USE GEOMETRY_MOD , ONLY : GEOMETRY
USE PARKIND1     , ONLY : JPIM, JPRB
USE YOMHOOK      , ONLY : LHOOK, DR_HOOK, JPHOOK
USE YOMDYN       , ONLY : TDYN

!     ------------------------------------------------------------------

IMPLICIT NONE

TYPE(GEOMETRY)    ,INTENT(IN)    :: YDGEOMETRY
TYPE(TDYN)        ,INTENT(IN)    :: YDDYN
INTEGER(KIND=JPIM),INTENT(IN)    :: KSPEC2V
INTEGER(KIND=JPIM),INTENT(IN)    :: KM 
INTEGER(KIND=JPIM),INTENT(IN)    :: KMLOC
INTEGER(KIND=JPIM),INTENT(IN)    :: KSTA 
INTEGER(KIND=JPIM),INTENT(IN)    :: KEND 
REAL(KIND=JPRB),   INTENT(IN)    :: PSDIVP (YDGEOMETRY%YRDIMV%NFLEVG,KSPEC2V)
REAL(KIND=JPRB),   INTENT(INOUT) :: PSPDIVP(YDGEOMETRY%YRDIMV%NFLEVG,KSPEC2V)


!     ------------------------------------------------------------------

REAL(KIND=JPRB) :: ZSDIVPL (YDGEOMETRY%YRDIMV%NFLEVG,KM:YDGEOMETRY%YRDIM%NSMAX,2)
REAL(KIND=JPRB) :: ZSPDIVPL(YDGEOMETRY%YRDIMV%NFLEVG,KM:YDGEOMETRY%YRDIM%NSMAX,2)

INTEGER(KIND=JPIM) :: II, IS0, IS02, ISE, JN

REAL(KIND=JPHOOK) :: ZHOOK_HANDLE

!     ------------------------------------------------------------------

#include "mxture.h"
#include "mxturs.h"

!     ------------------------------------------------------------------

IF (LHOOK) CALL DR_HOOK('SPCSIDG_PART1',0,ZHOOK_HANDLE)

ASSOCIATE(YDDIM=>YDGEOMETRY%YRDIM,YDDIMV=>YDGEOMETRY%YRDIMV,YDLAP=>YDGEOMETRY%YRLAP)
ASSOCIATE(NSMAX=>YDDIM%NSMAX,NFLEVG=>YDDIMV%NFLEVG,SIHEG=>YDDYN%SIHEG,SIHEG2=>YDDYN%SIHEG2)

!             Inversion of two tridiagonal systems (Helmholtz equation)
!                --> (SIMI*DIVprim(t+dt)).

!             Reorganisation of divergence

IS0=YDLAP%NSE0L(KMLOC)
IS02=0
II=MIN(KM,1)+1
ZSDIVPL(:,:,:)=0.0_JPRB
ZSPDIVPL(:,:,:)=0.0_JPRB

DO JN=KM,NSMAX
  ISE=KSTA+2*(JN-KM)
  ZSDIVPL(:,JN,1:2)=PSDIVP(:,ISE:ISE+1)
ENDDO
IF (KM > 0) THEN

  !               Inversion of a symmetric matrix.

  CALL MXTURS(NSMAX+1-KM,NFLEVG,NFLEVG,II,&
   & SIHEG(1,IS0+1,1),SIHEG(1,IS0+1,2),SIHEG(1,IS0+1,3),&
   & ZSDIVPL,ZSPDIVPL)  
ELSE

  !               Inversion of a non-symmetric matrix.

  CALL MXTURE(NSMAX+1-KM,NFLEVG,NFLEVG,II,-2,.TRUE.,&
   & SIHEG(1,IS0+1,1),SIHEG(1,IS0+1,2),SIHEG(1,IS0+1,3),&
   & ZSDIVPL,ZSPDIVPL)  
  CALL MXTURE(NSMAX+1-KM,NFLEVG,NFLEVG,II,3,.FALSE.,&
   & SIHEG(1,IS0+1,1),SIHEG2(1,IS02+1,2),&
   & SIHEG2(1,IS02+1,3),ZSDIVPL,ZSPDIVPL)  
ENDIF

DO JN=KM,NSMAX
  ISE=KSTA+2*(JN-KM)
  PSPDIVP(:,ISE:ISE+1)=ZSPDIVPL(:,JN,1:2)
ENDDO

END ASSOCIATE
END ASSOCIATE

IF (LHOOK) CALL DR_HOOK('SPCSIDG_PART1',1,ZHOOK_HANDLE)
END SUBROUTINE SPCSIDG_PART1

